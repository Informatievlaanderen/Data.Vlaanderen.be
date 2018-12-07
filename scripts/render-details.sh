#!/bin/bash

WORKDIR=$1
SUBDIR=$2
TEMPLATE=unknown

echo "render-details: starting with $1 $2 $3"

for $i in ${WORkDIR}/${SUBDIR}/*.jsonld
do
    OUTFILE=$(basename "$i" .json).html
    echo "render-details: convert $i to $OUTPUT"
    echo "node cls.js $i ${TEMPLATE} ${OUTPUT}"
done
