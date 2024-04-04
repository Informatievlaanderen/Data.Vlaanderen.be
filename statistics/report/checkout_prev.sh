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

# implementation notes
#  - git checkout HEAD^ will report error when there was no previous commit 
#    This is the case with this was the first commit of the specification




