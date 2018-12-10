#!/bin/bash

TARGETDIR=$1
SUBDIR=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

echo "render-details: starting with $1 $2 $3"

set -x

mkdir -p ${TARGETDIR}/html

cat ${CHECKOUTFILE} | while read line
do
    echo "Processing line: $line"
    if [ -d "$line" ]
    then
	pushd $line
	for i in *.jsonld
	do
	    echo "render-details: convert $i to html"
	    BASENAME=$(basename $i .jsonld)
	    OUTFILE=${BASENAME}.html
	    TYPE=$(jq -r '.[]|select(.name | contains("${BASENAME}"))|.type' .names.json)
	    TEMPLATE=${BASENAME}.j2
	    node cls.js $i templates/${BASENAME}-${TYPE}.j2 ${TARGETDIR}/html/${OUTFILE}
	done
	popd
    else
	echo "Error: $line"
    fi
done

