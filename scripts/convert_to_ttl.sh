#!/bin/bash

CLEANUP=$1

while read line
do
    BASENAME=$(basename ${line} .jsonld)
    BASEDIR=$(dirname ${line})
    OUTFILE=${BASEDIR}/${BASENAME}.ttl
    echo "converting file: ${line} => ${OUTFILE}"
    if [ -f "${line}" ]
    then
	mkdir -p ${BASEDIR}/jsonld
        rdf serialize --input-format jsonld --processingMode json-ld-1.1 $line --output-format turtle -o ${OUTFILE}
	mv ${line} ${BASEDIR}/jsonld
    else
	echo "Error: ${line}"
    fi
done
