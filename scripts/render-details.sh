#!/bin/bash

TARGETDIR=$1
SUBDIR=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

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
	    TEMPLATE=$(jq -r "${COMMAND}" .names.json)
	    echo "node /app/cls.js $i ${line}/templates/${TEMPLATE} ${TARGETDIR}/html/${OUTFILE}"
	    node /app/cls.js $i ${line}/templates/${TEMPLATE} ${TARGETDIR}/html/${OUTFILE}
	done
    else
	echo "Error: $line"
    fi
done
