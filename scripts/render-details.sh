#!/bin/bash

TARGETDIR=$1
SUBDIR=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt
export NODE_PATH=/app/node_modules

echo "render-details: starting with $1 $2 $3"

mkdir -p ${TARGETDIR}/html

cat ${CHECKOUTFILE} | while read line
do
    echo "Processing line: $line"
    if [ -d "$line" ]
    then
	for i in ${line}/*.jsonld
	do
	    echo "render-details: convert $i to html"
	    BASENAME=$(basename $i .jsonld)
	    OUTFILE=${BASENAME}.html
	    COMMAND=$(echo '.[]|select(.name | contains("'${BASENAME}'"))|.template')
	    TEMPLATE=$(jq -r "${COMMAND}" ${line}/.names.json)
	    # determine the location of the template to be used.
	    FTEMPLATE=/app/views/${TEMPLATE}
	    if [ ! -f "${FTEMPLATE}" ] ; then
	       FTEMPLATE=${line}/template/${TEMPLATE}
	    fi
	    echo "node /app/cls.js $i ${FTEMPLATE} ${TARGETDIR}/html/${OUTFILE}"
	    pushd /app
	      node /app/cls.js $i ${FTEMPLATE} ${TARGETDIR}/html/${OUTFILE}
	    popd
	done
    else
	echo "Error: $line"
    fi
done
