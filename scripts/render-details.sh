#!/bin/bash

TARGETDIR=$1
DETAILS=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt
export NODE_PATH=/app/node_modules

render_html() { # SLINE TLINE JSON
    echo "render_html: $1 $2 $3 $4 $5"     
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    local RLINE=$4
    local DROOT=$5
    
    BASENAME=$(basename ${JSONI} .jsonld)
#    OUTFILE=${BASENAME}.html
    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.template')
    TEMPLATE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)
    # determine the location of the template to be used.

    echo "RENDER-DETAILS(html): ${TEMPLATE} ${PWD}"	    
    # precendence order: local files > Data.vlaanderen.be > SpecGenerator
    # TODO: include a first copy from Data.vlaanderen.be 
    cp -n /app/views/* ${SLINE}/templates 
    mkdir -p ${RLINE}

    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.type')
    TYPE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)

    
    echo "RENDER-DETAILS(html): node /app/html-generator.js -s ${TYPE} -i ${JSONI} -x ${RLINE}/html-nj.json -r ${DROOT} -t ${TEMPLATE} -d ${SLINE}/templates -o ${TLINE}/index.html"
    pushd /app
      mkdir -p ${TLINE}/html
      if ! node /app/html-generator.js -s ${TYPE} -i ${JSONI} -t ${TEMPLATE} -x ${RLINE}/html-nj.json -d ${SLINE}/templates -r /${DROOT} -o ${TLINE}/index.html
      then
	  exit -1
      fi
      # make the report better readable
      jq . ${RLINE}/html-nj.json > ${RLINE}/html-nj.json2
      mv ${RLINE}/html-nj.json2 ${RLINE}/html-nj.json
    popd
}

touch2() { mkdir -p "$(dirname "$1")" && touch "$1" ; }

prettyprint_jsonld() {
    local FILE=$1
  
    if [ -f ${FILE} ] ;  then 
    	touch2 /tmp/pp/${FILE}
    	jq --sort-keys . ${FILE} > /tmp/pp/${FILE}
    	cp /tmp/pp/${FILE} ${FILE}
    fi
}

render_context() { # SLINE TLINE JSON
    echo "render_context: $1 $2 $3" 
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    local RLINE=$4    

    FILENAME=$(jq -r ".name" ${JSONI})
    OUTFILE=${FILENAME}.jsonld

    BASENAME=$(basename ${JSONI} .jsonld)
#    OUTFILE=${BASENAME}.jsonld

    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.type')
    TYPE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)

    if [ ${TYPE} == "ap"  ] || [ ${TYPE} == "oj" ]; then
      echo "RENDER-DETAILS(context): node /app/json-ld-generator.js -d -l label -i ${JSONI} -o ${TLINE}/context/${OUTFILE} "
      pushd /app
        mkdir -p ${TLINE}/context
        if ! node /app/json-ld-generator.js -d -l label -i ${JSONI} -o ${TLINE}/context/${OUTFILE}
	then
	    echo "RENDER-DETAILS: See XXX for more details"
	    exit -1
	fi
        prettyprint_jsonld ${TLINE}/context/${OUTFILE}
      popd
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
#      DOMAIN="https://data.vlaanderen.be/shacl/${BASENAME}"
      DOMAIN="https://data.vlaanderen.be/shacl/${FILENAME}"
      pushd /app
        mkdir -p ${TLINE}/shacl
	mkdir -p ${RLINE}/shacl      
        if ! node /app/shacl-generator.js -i ${JSONI} -d ${DOMAIN} -o ${OUTFILE} 2>&1 | tee ${OUTREPORT}
	then
	    echo "RENDER-DETAILS: See ${OUTREPORT} for the details"
	    exit -1
        fi
        prettyprint_jsonld ${OUTFILE}
      popd
    fi
}
		 
echo "render-details: starting with $1 $2 $3"

cat ${CHECKOUTFILE} | while read line
do
    SLINE=${TARGETDIR}/src/${line}
    TLINE=${TARGETDIR}/target/${line}
    RLINE=${TARGETDIR}/report/${line}
    echo "RENDER-DETAILS: Processing line ${SLINE} => ${TLINE},${RLINE}"
    if [ -d "${SLINE}" ]
    then
	for i in ${SLINE}/*.jsonld
	do
	    echo "RENDER-DETAILS: convert $i to ${DETAILS} ($PWD)"
	    case ${DETAILS} in
		html) RLINE=${TARGETDIR}/reporthtml/${line}
		      mkdir -p ${RLINE}
                      render_html $SLINE $TLINE $i $RLINE ${line}
		      ;;
               shacl) render_shacl $SLINE $TLINE $i $RLINE
		      ;;
	     context) render_context $SLINE $TLINE $i $RLINE
		      ;;
		   *)  echo "RENDER-DETAILS: ${DETAILS} not handled yet"
	    esac
	done
    else
	echo "Error: ${SLINE}"
    fi
done
