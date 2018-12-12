#!/bin/bash

TARGETDIR=$1
DETAILS=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt
export NODE_PATH=/app/node_modules

render_html() { # SLINE TLINE JSON
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
      node /app/cls.js ${JSONI} ${FTEMPLATE} ${TLINE}/html/${OUTFILE}
    popd
}

render_context() { # SLINE TLINE JSON
    echo "render_context: entered" 
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    BASENAME=$(basename ${JSONI} .jsonld)
    OUTFILE=${BASENAME}.html
    echo "node /app/json-ld-generator.js -i ${JSONI} -o ${TLINE}/json/${OUTFILE}"
    pushd /app
      mkdir -p ${TLINE}/json
      node /app/json-ld-generator.js -i ${JSONI} -o ${TLINE}/json/${OUTFILE}
    popd
}
		 
render_shacl() {
    echo "render_context: entered"
    local SLINE=$1
    local TLINE=$2
    local JSONI=$3
    BASENAME=$(basename ${JSONI} .jsonld)
    OUTFILE=${BASENAME}.html
    echo "node /app/shacl-generator.js -i ${JSONI} -o ${TLINE}/shacl/${OUTFILE}"
    pushd /app
      mkdir -p ${TLINE}/shacl
      node /app/shacl-generator.js -i ${JSONI} -o ${TLINE}/shacl/${OUTFILE}
    popd
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
	    echo "render-details: convert $i to ${DETAILS} ($CWD)"
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
