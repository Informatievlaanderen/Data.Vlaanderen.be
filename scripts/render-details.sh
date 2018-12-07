#!/bin/bash

WORKDIR=$1
SUBDIR=$2
TEMPLATE=unknown

echo "render-details: starting with $1 $2 $3"

for $i in ${WORkDIR}/${SUBDIR}/*.jsonld
do
    echo "render-details: convert $i to html"
    OUTFILE=$(basename $i .jsonld).html
    echo "node cls.js $i ${TEMPLATE} ${OUTFILE}"
done

