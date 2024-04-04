#!/bin/bash


INPUT=$1
OUTPUTDIR=$2
OUTPUTFILE=$3

OUTPUT=${OUTPUTDIR}${OUTPUTFILE}
mkdir -p ${OUTPUTDIR}

cp ${INPUT} ${OUTPUT}.orig
git checkout HEAD^ ${INPUT}
cp ${INPUT} ${OUTPUT}
git checkout ${INPUT}




