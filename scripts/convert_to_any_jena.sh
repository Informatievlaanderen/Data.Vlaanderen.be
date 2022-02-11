#!/bin/bash

FORMAT=$1

echo ${FORMAT}

case ${FORMAT} in
	turtle) EXT=ttl
	        ;;
	ntriples) EXT=nt
	        ;;
	rdfxml) EXT=rdf
	        ;;
	*) echo "ERROR: ${FORMAT} not defined, using default"
		FORMAT=turtle
	        EXT=ttl
		;;
esac

while read line
do
    BASENAME=$(basename ${line} .jsonld)
    BASEDIR=$(dirname ${line})
    OUTFILE=${BASEDIR}/${BASENAME}.${EXT}
    echo "converting file: ${line} => ${OUTFILE}"
    if [ -f "${line}" ]
    then
	riot --output turtle --syntax jsonld $line > ${OUTFILE}
	echo "rm -rf ${line}"
#	rm -rf ${line}
    else
	echo "Error: ${line}"
    fi
done
