#!/bin/bash

CLEANUP=$1

while read line
do
    BASENAME=$(basename ${line} .jsonld)
    OUTFILE=${BASENAME}.ttl
    if [ -d "${line}" ]
    then	
	echo "Processing line: ${line} => ${OUTFILE}"
        rdf serialize --input-format jsonld --processingMode json-ld-1.1 $line --output-format turtle -o ${OUTFILE}
	rm -f ${line}
    else
	echo "Error: ${line}"
    fi
done
