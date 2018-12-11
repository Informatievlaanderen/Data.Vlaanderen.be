#!/bin/bash

TARGETDIR=$1
SUBDIR=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

echo "generate-voc: starting with $1 $2 $3"

mkdir -p ${TARGETDIR}/html

cat ${CHECKOUTFILE} | while read line
do
    echo "Processing line: $line"
    if [ -d "$line" ]
    then
	for i in ${line}/*.jsonld
	do
	    echo "generate-voc: convert $i to RDF"
	    BASENAME=$(basename $i .jsonld)
	    OUTFILE=${BASENAME}.ttl

            rdf serialize --input-format jsonld --processingMode json-ld-1.1 $i --output-format turtle -o /tmp/workspace/voc/$BASENAME.ttl
	done
    else
	echo "Error: $line"
    fi
done
