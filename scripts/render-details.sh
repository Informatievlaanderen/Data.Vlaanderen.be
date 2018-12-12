#!/bin/bash

TARGETDIR=$1
SUBDIR=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt
export NODE_PATH=/app/node_modules

echo "render-details: starting with $1 $2 $3"

mkdir -p ${TARGETDIR}/html

cat ${CHECKOUTFILE} | while read line
do
    SLINE=${TARGETDIR}/src/${line}
    TLINE=${TARGETDIR}/target/${line}
    echo "Processing line: ${SLINE} => ${TLINE}"
    if [ -d "${SLINE}" ]
    then
	for i in ${SLINE}/*.jsonld
	do
	    echo "render-details: convert $i to html"
	    BASENAME=$(basename $i .jsonld)
	    OUTFILE=${BASENAME}.html
	    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.template')
	    TEMPLATE=$(jq -r "${COMMAND}" ${SLINE}/.names.json)
	    # determine the location of the template to be used.
	    FTEMPLATE=/app/views/${TEMPLATE}
	    if [ ! -f "${FTEMPLATE}" ] ; then
	       FTEMPLATE=${SLINE}/template/${TEMPLATE}
	    fi
	    echo "node /app/cls.js $i ${FTEMPLATE} ${SLINE}/html/${OUTFILE}"
	    pushd /app
	      mkdir -p ${TLINE}/html
	      node /app/cls.js $i ${FTEMPLATE} ${TLINE}/html/${OUTFILE}
	    popd
	done
    else
	echo "Error: ${SLINE}"
    fi
done
