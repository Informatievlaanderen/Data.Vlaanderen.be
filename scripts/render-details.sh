#!/bin/bash

TARGETDIR=$1
DETAILS=$2
CONFIGDIR=$3

PRIMELANGUAGECONFIG=$(jq -r .primeLanguage ${CONFIGDIR}/config.json)
GOALLANGUAGECONFIG=$(jq -r '.otherLanguages | @sh'  ${CONFIGDIR}/config.json)
GOALLANGUAGECONFIG=`echo ${GOALLANGUAGECONFIG} | sed -e "s/'//g"`

PRIMELANGUAGE=${4-${PRIMELANGUAGECONFIG}}
GOALLANGUAGE=${5-${GOALLANGUAGECONFIG}}

STRICT=$(jq -r .toolchain.strickness ${CONFIGDIR}/config.json)
HOSTNAME=$(jq -r .hostname ${CONFIGDIR}/config.json)

CHECKOUTFILE=${TARGETDIR}/checkouts.txt
export NODE_PATH=/app/node_modules

execution_strickness() {
	if [ "${STRICT}" != "lazy" ] ; then
		exit -1
	fi
}

render_merged_files() {
    echo "Rendering the merged version of $1 with the json in $2 from $3 and to $4"
    local JSONI=$1
    local LANGUAGE=$2
    local SLINE=$3
    local TRLINE=$4
    local RLINE=$5

    COMMANDLANGJSON=$(echo '.[].translation | .[] | select(.language | contains("'${LANGUAGE}'")) | .translationjson')
    TRANSLATIONFILE=${TRLINE}/translation/$(jq -r "${COMMANDLANGJSON}" ${SLINE}/.names.json)

    COMMANDJSONLD=$(echo '.[].translation | .[] | select(.language | contains("'${LANGUAGE}'")) | .mergefile')
    MERGEDJSONLD=${RLINE}/translation/$(jq -r "${COMMANDJSONLD}" ${SLINE}/.names.json)
    MERGEDJSONLDDIR=$(dirname ${MERGEDJSONLD})
    echo "check for error $MERGEDJSONLD"
    echo "check for error $MERGEDJSONLDDIR"
    mkdir -p ${MERGEDJSONLDDIR}

    if [ -f "${TRANSLATIONFILE}" ]; then
        echo "${TRANSLATIONFILE} exists, the files will now be merged."
        echo "RENDER-DETAILS(mergefile): node /app/jsonld-merger.js -i ${JSONI} -m ${TRANSLATIONFILE} -l ${LANGUAGE} -o ${MERGEDJSONLD}"
        if ! node /app/jsonld-merger.js -i ${JSONI} -m ${TRANSLATIONFILE} -l ${LANGUAGE} -o ${MERGEDJSONLD}; then
            echo "RENDER-DETAILS: failed"
	    execution_strickness
        else
            echo "RENDER-DETAILS: Files succesfully merged and saved to: ${MERGEDJSONLD}"
            prettyprint_jsonld ${MERGEDJSONLD}
        fi
    else
        echo "${TRANSLATIONFILE} does not exist, nothing to merge. Just copy it"
	cp ${JSONI} ${MERGEDJSONLD}
    fi
}

render_translationfiles() {
    echo "checking if translationfile exists for primelanguage $1, goallanguage $2 and file $3 in the directory $4"
    local PRIMELANGUAGE=$1
    local GOALLANGUAGE=$2
    local JSONI=$3
    local SLINE=$4
    local TLINE=$5

    COMMANDLANGJSON=$(echo '.[].translation | .[] | select(.language | contains("'${GOALLANGUAGE}'")) | .translationjson')
    JSON=$(jq -r "${COMMANDLANGJSON}" ${SLINE}/.names.json)
    # secure the case that the translation file is not mentioned
    if [ "${JSON}" == ""  ] || [ "${JSON}" == "null" ] ; then
         COMMANDNAME=$(echo '.[].name')
          JSON=$(jq -r "${COMMANDNAME}" ${SLINE}/.names.json)
         JSON="${JSON}_${GOALLANGUAGE}.json"
    fi

    FILE=${SLINE}/translation/${JSON}

    mkdir -p ${TLINE}/translation
    OUTPUTFILE=${TLINE}/translation/${JSON}

    if [ -f "${FILE}" ]; then
        echo "${FILE} exists."
        echo "UPDATE-TRANSLATIONFILE: node /app/translation-json-update.js -i ${FILE} -f ${JSONI} -m ${PRIMELANGUAGE} -g ${GOALLANGUAGE} -o ${OUTPUTFILE}"
        if ! node /app/translation-json-update.js -i ${FILE} -f ${JSONI} -m ${PRIMELANGUAGE} -g ${GOALLANGUAGE} -o ${OUTPUTFILE}; then
            echo "RENDER-DETAILS: failed"
            execution_strickness
        else
            echo "RENDER-DETAILS: File succesfully updated"
            pretty_print_json ${OUTPUTFILE}
        fi
    else
        echo "${FILE} does not exist"
        echo "CREATE-TRANSLATIONFILE: node /app/translation-json-generator.js -i ${JSONI} -m ${PRIMELANGUAGE} -g ${GOALLANGUAGE} -o ${OUTPUTFILE}"
        if ! node /app/translation-json-generator.js -i ${JSONI} -m ${PRIMELANGUAGE} -g ${GOALLANGUAGE} -o ${OUTPUTFILE}; then
            echo "RENDER-DETAILS: failed"
            execution_strickness
        else
            echo "RENDER-DETAILS: File succesfully created"
            pretty_print_json ${OUTPUTFILE}
        fi
    fi
}

render_html() { # SLINE TLINE JSON
    echo "render_html: $1 $2 $3 $4 $5 $6 $7"
    echo "render_html: $1 $2 $3 $4 $5"
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    local RLINE=$4
    local DROOT=$5
    local RRLINE=$6
    local LANGUAGE=$7
    local PRIMELANGUAGE=${8-false}

    BASENAME=$(basename ${JSONI} .jsonld)
    #    OUTFILE=${BASENAME}.html
    # precendence order: Theme repository > publication repository > tool repository
    cp -n ${HOME}/project/templates/* ${SLINE}/templates
    cp -n /app/views/* ${SLINE}/templates
    #cp -n ${HOME}/project/templates/icons/* ${SLINE}/templates/icons
    mkdir -p ${RLINE}

    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.type')
    TYPE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)

    pushd /app
    mkdir -p ${TLINE}/html

    OUTPUT=${TLINE}/index_${LANGUAGE}.html
    COMMANDTEMPLATELANG=$(echo '.[].translation | .[] | select(.language | contains("'${LANGUAGE}'")) | .template')
    TEMPLATELANG=$(jq -r "${COMMANDTEMPLATELANG}" ${SLINE}/.names.json)
    COMMANDJSONLD=$(echo '.[].translation | .[] | select(.language | contains("'${LANGUAGE}'")) | .mergefile')
    LANGUAGEFILENAMEJSONLD=$(jq -r "${COMMANDJSONLD}" ${SLINE}/.names.json)
    if [ "${LANGUAGEFILENAMEJSONLD}" == "" ] ; then
	    echo "configuration for language ${GOALLANGUAGE} not present. Ignore this language for ${SLINE}"
    else 
	
    MERGEDJSONLD=${RRLINE}/translation/${LANGUAGEFILENAMEJSONLD}

    echo "RENDER-DETAILS(language html): node /app/html-generator2.js -s ${TYPE} -i ${MERGEDJSONLD} -x ${RLINE}/html-nj_${LANGUAGE}.json -r /${DROOT} -t ${TEMPLATELANG} -d ${SLINE}/templates -o ${OUTPUT} -m ${LANGUAGE} -e ${RRLINE}"

    if ! node /app/html-generator2.js -s ${TYPE} -i ${MERGEDJSONLD} -x ${RLINE}/html-nj_${LANGUAGE}.json -r /${DROOT} -t ${TEMPLATELANG} -d ${SLINE}/templates -o ${OUTPUT} -m ${LANGUAGE} -e ${RRLINE}; then
        echo "RENDER-DETAILS(language html): rendering failed"
	execution_strickness
    else
	if [ ${PRIMELANGUAGE} == true ] ; then
		cp ${OUTPUT} ${TLINE}/index.html
	fi
        echo "RENDER-DETAILS(language html): File was rendered in ${OUTPUT}"
    fi

    pretty_print_json ${RLINE}/html-nj_${LANGUAGE}.json
    popd
    fi
}

link_html() { # SLINE TLINE JSON
    echo "link_html: $1 $2 $3 $4 $5 $6 $7"
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    local RLINE=$4
    local DROOT=$5
    local RRLINE=$6
    local LANGUAGE=$7

}

function pretty_print_json() {
	# echo "pretty_print_json: $1"
	if [ -f "$1" ] ; then
	   jq . $1 > /tmp/pp.json
	   mv /tmp/pp.json $1
	fi
}

render_example_template() { # SLINE TLINE JSON
    echo "render_example_template: $1 $2 $3 $4 $5 $6 $7"
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    local RLINE=$4
    local DROOT=$5
    local RRLINE=$6
    local LANGUAGE=$7
    BASENAME=$(basename ${JSONI} .jsonld)
    mkdir -p ${RLINE}
    touch ${RLINE}/

    COMMANDTYPE=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.type')
    TYPE=$(jq -r "${COMMANDTYPE}" ${SLINE}/.names.json)

    OUTPUT=/tmp/workspace/examples/${DROOT}
    mkdir -p ${OUTPUT}
    mkdir -p ${OUTPUT}/context
    touch ${OUTPUT}/.gitignore

    COMMANDJSONLD=$(echo '.[].translation | .[] | select(.language | contains("'${LANGUAGE}'")) | .mergefile')
    MERGEDJSONLD=${RRLINE}/translation/$(jq -r "${COMMANDJSONLD}" ${SLINE}/.names.json)
    #       cat ${MERGEDJSONLD}
    COMMAND=$(echo '.examples')
    EXAMPLE=$(jq -r "${COMMAND}" ${MERGEDJSONLD})
    echo "example " ${EXAMPLE}
    if [ "${EXAMPLE}" == true ]; then
        echo "RENDER-DETAILS(example generator): node /app/exampletemplate-generator2.js -i ${MERGEDJSONLD} -o ${OUTPUT} -l ${LANGUAGE} -h /doc/${TYPE}/${BASENAME}"
        if ! node /app/exampletemplate-generator2.js -i ${MERGEDJSONLD} -o ${OUTPUT} -l ${LANGUAGE} -h /doc/${TYPE}/${BASENAME}; then
            echo "RENDER-DETAILS(example generator): rendering failed"
            execution_strickness
        else
            echo "RENDER-DETAILS(example generator): Files were rendered in ${OUTPUT}"
        fi
    fi
}

touch2() { mkdir -p "$(dirname "$1")" && touch "$1"; }

prettyprint_jsonld() {
    local FILE=$1

    if [ -f ${FILE} ]; then
        touch2 /tmp/pp/${FILE}
        jq --sort-keys . ${FILE} >/tmp/pp/${FILE}
        cp /tmp/pp/${FILE} ${FILE}
    fi
}

render_context() { # SLINE TLINE JSON
    echo "render_context: $1 $2 $3 $4 $5"
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    local RLINE=$4
    local GOALLANGUAGE=$5
    local PRIMELANGUAGE=${6-false}

    FILENAME=$(jq -r ".name" ${JSONI})
    OUTFILE=${FILENAME}.jsonld
    OUTFILELANGUAGE=${FILENAME}_${GOALLANGUAGE}.jsonld

    BASENAME=$(basename ${JSONI} .jsonld)
    #    OUTFILE=${BASENAME}.jsonld

    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.type')
    TYPE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)

    if [ ${TYPE} == "ap" ] || [ ${TYPE} == "oj" ]; then
        echo "RENDER-DETAILS(context): node /app/json-ld-generator.js -d -l label -i ${JSONI} -o ${TLINE}/context/${OUTFILELANGUAGE} "
        mkdir -p ${TLINE}/context
        COMMANDJSONLD=$(echo '.[].translation | .[] | select(.language | contains("'${GOALLANGUAGE}'")) | .mergefile')
        LANGUAGEFILENAMEJSONLD=$(jq -r "${COMMANDJSONLD}" ${SLINE}/.names.json)
	if [ "${LANGUAGEFILENAMEJSONLD}" == "" ] ; then
	    echo "configuration for language ${GOALLANGUAGE} not present. Ignore this language for ${SLINE}"
        else 
	
        MERGEDJSONLD=${RLINE}/translation/${LANGUAGEFILENAMEJSONLD}

        echo "RENDER-DETAILS(context-language-aware): node /app/json-ld-generator2.js -d -l label -i ${MERGEDJSONLD} -o ${TLINE}/context/${OUTFILELANGUAGE} -m ${GOALLANGUAGE}"
        if ! node /app/json-ld-generator2.js -d -l label -i ${MERGEDJSONLD} -o ${TLINE}/context/${OUTFILELANGUAGE} -m ${GOALLANGUAGE}; then
            echo "RENDER-DETAILS(context-language-aware): See XXX for more details, Rendering failed"
            execution_strickness
        else
            echo "RENDER-DETAILS(context-language-aware): Rendering successfull, File saved to  ${TLINE}/context/${OUTFILELANGUAGE}"
        fi

        prettyprint_jsonld ${TLINE}/context/${OUTFILELANGUAGE}
	if [ ${PRIMELANGUAGE} == true ] ; then
		cp ${TLINE}/context/${OUTFILELANGUAGE} ${TLINE}/context/${OUTFILE}
	fi

	fi 
    fi
}

render_shacl() {
    echo "render_shacl: $1 $2 $3 $4"
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    local RLINE=$4

    FILENAME=$(jq -r ".name" ${JSONI})
    OUTFILE=${TLINE}/shacl/${FILENAME}-SHACL.jsonld
    OUTREPORT=${RLINE}/shacl/${FILENAME}-SHACL.report

    BASENAME=$(basename ${JSONI} .jsonld)
    #    OUTFILE=${TLINE}/shacl/${BASENAME}-SHACL.jsonld
    #    OUTREPORT=${RLINE}/shacl/${BASENAME}-SHACL.report

    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.type')
    TYPE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)

    if [ ${TYPE} == "ap" ] || [ ${TYPE} == "oj" ]; then
        echo "RENDER-DETAILS(shacl): node /app/shacl-generator.js -i ${JSONI} -o ${OUTFILE}"
        DOMAIN="${HOSTNAME}/shacl/${FILENAME}"
        pushd /app
        mkdir -p ${TLINE}/shacl
        mkdir -p ${RLINE}/shacl
        if ! node /app/shacl-generator.js -i ${JSONI} -d ${DOMAIN} -o ${OUTFILE} 2>&1 | tee ${OUTREPORT}; then
            echo "RENDER-DETAILS: See ${OUTREPORT} for the details"
            execution_strickness
        fi
        prettyprint_jsonld ${OUTFILE}
        popd
    fi
}

render_shacl_languageaware() {
    echo "render_shacl: $1 $2 $3 $4 $5"
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    local RLINE=$4
    local LINE=$5
    local GOALLANGUAGE=$6
    local PRIMELANGUAGE=${7-false}

    FILENAME=$(jq -r ".name" ${JSONI})
    COMMANDJSONLD=$(echo '.[].translation | .[] | select(.language | contains("'${GOALLANGUAGE}'")) | .mergefile')
    LANGUAGEFILENAMEJSONLD=$(jq -r "${COMMANDJSONLD}" ${SLINE}/.names.json)

    if [ "${LANGUAGEFILENAMEJSONLD}" == "" ] ; then
	    echo "configuration for language ${GOALLANGUAGE} not present. Ignore this language for ${SLINE}"
    else 

    MERGEDJSONLD=${RLINE}/translation/${LANGUAGEFILENAMEJSONLD}
    OUTFILE=${TLINE}/shacl/${FILENAME}-SHACL_${GOALLANGUAGE}.jsonld
    OUTREPORT=${RLINE}/shacl/${FILENAME}-SHACL_${GOALLANGUAGE}.report

    BASENAME=$(basename ${JSONI} .jsonld)

    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.type')
    TYPE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)

    if [ ${TYPE} == "ap" ] || [ ${TYPE} == "oj" ]; then
        DOMAIN="${HOSTNAME}/${LINE}"
        echo "RENDER-DETAILS(shacl-languageaware): node /app/shacl-generator.js -i ${MERGEDJSONLD} -m individual -c 'uniqueLanguages' -c 'nodekind' -d ${DOMAIN} -p ${DOMAIN} -o ${OUTFILE} -l ${GOALLANGUAGE}"
        pushd /app
        mkdir -p ${TLINE}/shacl
        mkdir -p ${RLINE}/shacl
        if ! node /app/shacl-generator2.js -i ${MERGEDJSONLD} -m individual -c 'uniqueLanguages' -c 'nodekind' -d ${DOMAIN} -p ${DOMAIN} -o ${OUTFILE} -l ${GOALLANGUAGE} 2>&1 | tee ${OUTREPORT}; then
            echo "RENDER-DETAILS(shacl-languageaware): See ${OUTREPORT} for the details"
            execution_strickness
        else
            echo "RENDER-DETAILS(shacl-languageaware): saved to ${OUTFILE}"
        fi
        prettyprint_jsonld ${OUTFILE}
	if [ ${PRIMELANGUAGE} == true ] ; then
		cp ${OUTFILE} ${TLINE}/shacl/${FILENAME}-SHACL.jsonld
	fi
        popd
    fi
    fi
}

write_report() {
    echo "Rendering the reportfiles of $1 with the json in $2 from $3 and to $4"
    local JSONI=$1
    local LANGUAGE=$2
    local SLINE=$3
    local TRLINE=$4
    local RLINE=$5

    mkdir -p /tmp/workspace/report/translation
    FILENAME=$(jq -r ".name" ${JSONI})_${GOALLANGUAGE}
    COMMANDLANGJSON=$(echo '.[].translation | .[] | select(.language | contains("'${LANGUAGE}'")) | .translationjson')
    TRANSLATIONFILE=${TRLINE}/translation/$(jq -r "${COMMANDLANGJSON}" ${SLINE}/.names.json)
    REPORTFILE=/tmp/workspace/report/translation/${FILENAME}.report

    if [ -f "${TRANSLATIONFILE}" ]; then
        echo "${TRANSLATIONFILE} exists, the file will now be reviewed."
        echo "RENDER-DETAILS(mergefile): node /app/generate-translation-report.js -i ${TRANSLATIONFILE} -l ${LANGUAGE} -o ${REPORTFILE}"
        if ! node /app/generate-translation-report.js -i ${TRANSLATIONFILE} -l ${LANGUAGE} -o ${REPORTFILE}; then
            echo "RENDER-DETAILS: failed"
            execution_strickness
        else
            echo "RENDER-DETAILS: Report succesfully created and saved to: ${REPORTFILE}"
        fi
    else
        echo "${TRANSLATIONFILE} does not exist, nothing to validate."
    fi
}

echo "render-details: starting with $1 $2 $3"

cat ${CHECKOUTFILE} | while read line; do
    SLINE=${TARGETDIR}/src/${line}
    TLINE=${TARGETDIR}/target/${line}
    RLINE=${TARGETDIR}/report/${line}
    TRLINE=${TARGETDIR}/translation/${line}
    echo "RENDER-DETAILS: Processing line ${SLINE} => ${TLINE},${RLINE}"
    if [ -d "${SLINE}" ]; then
        for i in ${SLINE}/*.jsonld; do
            echo "RENDER-DETAILS: convert $i to ${DETAILS} ($PWD)"
            case ${DETAILS} in
            html)
                RLINE=${TARGETDIR}/reporthtml/${line}
                mkdir -p ${RLINE}
                render_html $SLINE $TLINE $i $RLINE ${line} ${TARGETDIR}/report/${line} ${PRIMELANGUAGE} true
		for g in ${GOALLANGUAGE} 
		do 
                render_html $SLINE $TLINE $i $RLINE ${line} ${TARGETDIR}/report/${line} ${g}
	        done
                ;;
            shacl) # render_shacl $SLINE $TLINE $i $RLINE
                render_shacl_languageaware $SLINE $TLINE $i $RLINE ${line} ${PRIMELANGUAGE} true
		for g in ${GOALLANGUAGE} 
		do 
                render_shacl_languageaware $SLINE $TLINE $i $RLINE ${line} ${g}
	        done
                ;;
            context)
                render_context $SLINE $TLINE $i $RLINE ${PRIMELANGUAGE} true
		for g in ${GOALLANGUAGE} 
		do 
                render_context $SLINE $TLINE $i $RLINE ${g} 
	        done
                ;;
            multilingual)
		for g in ${GOALLANGUAGE} 
		do 
                render_translationfiles ${PRIMELANGUAGE} ${g} $i ${SLINE} ${TRLINE}
	        done
                render_translationfiles ${PRIMELANGUAGE} ${PRIMELANGUAGE} $i ${SLINE} ${TRLINE}
                ;;
            merge)
                render_merged_files $i ${PRIMELANGUAGE} ${SLINE} ${TRLINE} ${RLINE}
		for g in ${GOALLANGUAGE} 
	        do
                render_merged_files $i ${g} ${SLINE} ${TRLINE} ${RLINE}
	        done
                ;;
            report)
                write_report $i ${PRIMELANGUAGE} ${SLINE} ${TRLINE} ${RLINE}
		for g in ${GOALLANGUAGE} 
		do
                write_report $i ${g} ${SLINE} ${TRLINE} ${RLINE}
	        done
                ;;
            example)
                render_example_template $SLINE $TLINE $i $RLINE ${line} ${TARGETDIR}/report/${line} ${PRIMELANGUAGE}
		for g in ${GOALLANGUAGE} 
		do
                render_example_template $SLINE $TLINE $i $RLINE ${line} ${TARGETDIR}/report/${line} ${g}
	        done
                ;;
            *) echo "RENDER-DETAILS: ${DETAILS} not handled yet" ;;
            esac
        done
    else
        echo "Error: ${SLINE}"
    fi
done
