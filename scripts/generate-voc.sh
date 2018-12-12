#!/bin/bash

TARGETDIR=$1
SUBDIR=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

echo "generate-voc: starting with $1 $2 $3"

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
	    echo "generate-voc: convert $i to RDF"
	    BASENAME=$(basename $i .jsonld)
	    OUTFILE=${BASENAME}.ttl

	    mkdir -p ${TLINE}/voc
            rdf serialize --input-format jsonld --processingMode json-ld-1.1 $i --output-format turtle -o ${TLINE}/voc/$BASENAME.ttl
	done
    else
	echo "Error: ${SLINE}"
    fi
done
