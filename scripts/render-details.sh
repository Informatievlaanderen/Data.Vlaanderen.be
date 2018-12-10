#!/bin/bash

WORKDIR=$1
SUBDIR=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

echo "render-details: starting with $1 $2 $3"

mkdir -p ${WORKDIR}/html

cat ${CHECKOUTFILE} | while read line
do
    echo "Processing line ($extractwhat): $line"
    if [ -d "$line" ]
    then
	pushd $line
	for i in *.jsonld
	do
	    echo "render-details: convert $i to html"
	    OUTFILE=$(basename $i .jsonld).html
	    TEMPLATE=$(basename $i .jsonld).j2
	    node cls.js $i ${TEMPLATE} ${WORKDIR}/html/${OUTFILE}
	done
	popd
    else
	echo "Error: $line"
    fi
done

