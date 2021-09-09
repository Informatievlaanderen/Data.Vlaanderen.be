#!/bin/bash

TARGETDIR=$1
SUBDIR=$2
CONFIGDIR=$3
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

#############################################################################################
PRIMELANGUAGECONFIG=$(jq -r .primeLanguage ${CONFIGDIR}/config.json)
GOALLANGUAGECONFIG=$(jq -r '.otherLanguages | @sh'  ${CONFIGDIR}/config.json)

PRIMELANGUAGE=${4-${PRIMELANGUAGECONFIG}}
GOALLANGUAGE=${5-${GOALLANGUAGECONFIG}}

echo "generate-voc: starting with $1 $2 $3"

#############################################################################################
is_vocabulary() {
    local RLINE=$1
    local SLINE=$2
    COMMANDJSONLD=$(echo '.[].type')
    TYPE=$(jq -r "${COMMANDJSONLD}" ${SLINE}/.names.json)

    if [ "${TYPE}" == "voc" ];  then
       return 0
    else 
       return 1
    fi

}


make_jsonld() {
    local FILE=$1
    local INPUT=$2
    local TARGET=$3
    local CONFIGDIR=$4
    local LANGUAGE=$5
    local RLINE=$6
    local SLINE=$7

    RETURN=1
    mkdir -p /tmp/${FILE}
    COMMANDJSONLD=$(echo '.[].translation | .[] | select(.language | contains("'${LANGUAGE}'")) | .mergefile')
    MERGEDJSONLD=${RLINE}/translation/$(jq -r "${COMMANDJSONLD}" ${SLINE}/.names.json)
    OUTPUT=${RLINE}/translation/voc_${LANGUAGE}.jsonld

    if [ -f ${MERGEDJSONLD} ] ; then
    echo "RENDER-DETAILS(voc-languageaware): node /app/render-voc.js -i ${MERGEDJSONLD} -o ${OUTPUT} -l ${LANGUAGE}"
    if ! node /app/render-voc.js -i ${MERGEDJSONLD} -o ${OUTPUT} -l ${LANGUAGE}
    then
        echo "RENDER-DETAILS(voc-languageaware): See ${OUTREPORT} for the details"
	RETURN=-1
        exit -1
    else
        echo "RENDER-DETAILS(voc-languageaware): saved to ${OUTPUT}"
        echo "RENDER-DETAILS(voc-languageaware): It will now be concatted and saved to ${TARGET}"

         if [ -f ${CONFIGDIR}/ontology.defaults.json ]
        then
            if [ -f /tmp/${FILE}/ontology ]
            then
                jq -s '.[0] + .[1] + .[2] + .[3]' /tmp/${FILE}/ontology ${CONFIGDIR}/ontology.defaults.json ${OUTPUT} ${CONFIGDIR}/context >  ${TARGET}
            else
                jq -s '.[0] + .[1] + .[2]' ${CONFIGDIR}/ontology.defaults.json ${OUTPUT} ${CONFIGDIR}/context >  ${TARGET}
            fi
        else
            if [ -f /tmp/${FILE}/ontology ]
            then
                jq -s '.[0] + .[1] + .[2]' /tmp/${FILE}/ontology ${OUTPUT} ${CONFIGDIR}/context >  ${TARGET}
            else
                jq -s '.[0] + .[1]' ${OUTPUT} ${CONFIGDIR}/context >  ${TARGET}
            fi
        fi
    fi
    else
       echo "RENDER-DETAILS(voc-languageaware): ERROR ${MERGEDJSONLD} has not been created in previous step"
       echo "RENDER-DETAILS(voc-languageaware): continue with next specification"
       RETURN=0
    fi


}
#############################################################################################

mkdir -p ${TARGETDIR}/html

cat ${CHECKOUTFILE} | while read line
do
    SLINE=${TARGETDIR}/src/${line}
    TLINE=${TARGETDIR}/target/${line}
    RLINE=${TARGETDIR}/report/${line}
    echo "Processing line: ${SLINE} => ${TLINE} ${RLINE}"
    if [ -d "${SLINE}" ]
    then
            for i in ${SLINE}/*.jsonld
            do
		if is_vocabulary ${RLINE} ${SLINE} ;  then
                echo "generate-voc: convert $i to RDF"
                BASENAME=$(basename $i .jsonld)
                OUTFILE=${BASENAME}.ttl
                REPORT=${RLINE}/${BASENAME}.ttl-report

		echo "render vocabulary for prime language ${PRIMELANGUAGE}"
                mkdir -p ${TLINE}/voc
                make_jsonld $BASENAME $i ${SLINE}/selected_${PRIMELANGUAGE}.jsonld ${CONFIGDIR} ${PRIMELANGUAGE} ${RLINE} ${SLINE}
		if [ ${RETURN} -gt 0 ] ; then
                     cp ${SLINE}/selected_${PRIMELANGUAGE}.jsonld ${TLINE}/voc/${BASENAME}_${PRIMELANGUAGE}.jsonld
                     cp ${SLINE}/selected_${PRIMELANGUAGE}.jsonld ${TLINE}/voc/${BASENAME}.jsonld
		fi


		#
		# do not execute the processing for other languages because RDF vocabularies are normally multilingual
		# The current tool does not aggregate the different languages. This is a next step
		#
		for g in ${GOALLANGUAGE} 
		do 
			echo "render vocabulary for goal language ${g}"
                	make_jsonld $BASENAME $i ${SLINE}/selected_${g}.jsonld ${CONFIGDIR} ${g} ${RLINE} ${SLINE} 
			if [ ${RETURN} -gt 0 ] ; then
                	cp ${SLINE}/selected_${g}.jsonld ${TLINE}/voc/${BASENAME}_${g}.jsonld
			fi
		done
                fi
            done
    else
	    echo "Error: ${SLINE}"
    fi
done



