#!/bin/bash

TARGETDIR=$1
DETAILS=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt
export NODE_PATH=/app/node_modules

render_html() { # SLINE TLINE JSON
    echo "render_htm: $1 $2 $3"     
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    BASENAME=$(basename ${JSONI} .jsonld)
    OUTFILE=${BASENAME}.html
    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.template')
    TEMPLATE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)
    # determine the location of the template to be used.

    echo "render-details: ${TEMPLATE} ${PWD}"	    
    FTEMPLATE=/app/views/${TEMPLATE}
    if [ ! -f "${FTEMPLATE}" ] ; then
	FTEMPLATE=${SLINE}/template/${TEMPLATE}
    fi
    
    echo "node /app/cls.js ${JSONI} ${FTEMPLATE} ${TLINE}/html/${OUTFILE}"
    pushd /app
      mkdir -p ${TLINE}/html
      if ! node /app/cls.js ${JSONI} ${FTEMPLATE} ${TLINE}/html/${OUTFILE}
      then
	  exit -1
      fi
    popd
}

render_context() { # SLINE TLINE JSON
    echo "render_context: $1 $2 $3" 
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    BASENAME=$(basename ${JSONI} .jsonld)
    OUTFILE=${BASENAME}.jsonld

    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.type')
    TYPE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)

    if [ $TYPE == "ap" ]; then
      echo "node /app/json-ld-generator.js -i ${JSONI} -o ${TLINE}/json/${OUTFILE}"
      pushd /app
        mkdir -p ${TLINE}/json
        node /app/json-ld-generator.js -i ${JSONI} -o ${TLINE}/json/${OUTFILE} || exit -1
      popd
    fi
}
		 
render_shacl() {
    echo "render_shacl: $1 $2 $3"
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    BASENAME=$(basename ${JSONI} .jsonld)
    OUTFILE=${TLINE}/shacl/${BASENAME}-SHACL.jsonld
    OUTREPORT=${TLINE}/shacl/${BASENAME}-SHACL.report

    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.type')
    TYPE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)

    if [ $TYPE == "ap" ]; then
      echo "node /app/shacl-generator.js -i ${JSONI} -o ${OUTFILE}"
      pushd /app
        mkdir -p ${TLINE}/shacl
        node /app/shacl-generator.js -i ${JSONI} -o ${OUTFILE} 2>&1 | tee ${OUTREPORT} || exit -1
      popd
    fi
}
		 
echo "render-details: starting with $1 $2 $3"

cat ${CHECKOUTFILE} | while read line
do
    SLINE=${TARGETDIR}/src/${line}
    TLINE=${TARGETDIR}/target/${line}
    echo "Processing line: ${SLINE} => ${TLINE}"
    if [ -d "${SLINE}" ]
    then
	for i in ${SLINE}/*.jsonld
	do
	    echo "render-details: convert $i to ${DETAILS} ($PWD)"
	    case ${DETAILS} in
		html) render_html $SLINE $TLINE $i
		      ;;
               shacl) render_shacl $SLINE $TLINE $i
		      ;;
	     context) render_context $SLINE $TLINE $i
		      ;;
		   *)  echo "${DETAILS} not handled yet"
	    esac
	done
    else
	echo "Error: ${SLINE}"
    fi
done
