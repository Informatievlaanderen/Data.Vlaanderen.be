#!/bin/bash

TARGETDIR=$1
DETAILS=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt
export NODE_PATH=/app/node_modules

render_html() {
    BASENAME=$(basename $i .jsonld)
    OUTFILE=${BASENAME}.html
    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.template')
    TEMPLATE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)
    # determine the location of the template to be used.

    echo "render-details: ${TEMPLATE}"	    
    FTEMPLATE=/app/views/${TEMPLATE}
    if [ ! -f "${FTEMPLATE}" ] ; then
	FTEMPLATE=${SLINE}/template/${TEMPLATE}
    fi
    
    echo "node /app/cls.js $i ${FTEMPLATE} ${TLINE}/html/${OUTFILE}"
    pushd /app
      mkdir -p ${TLINE}/html
      node /app/cls.js $i ${FTEMPLATE} ${TLINE}/html/${OUTFILE}
    popd
}

render_context() {
    echo "render_context: entered"
    ls /app    
}
		 
render_shacl() {
    echo "render_context: entered"
    ls /app
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
		html) render_html $SLINE $TLINE
		      ;;
               shacl) render_shacl $SLINE $TLINE
		      ;;
	     context) render_context $SLINE $TLINE
		      ;;
		   *)  echo "${DETAILS} not handled yet"
	    esac
	done
    else
	echo "Error: ${SLINE}"
    fi
done
