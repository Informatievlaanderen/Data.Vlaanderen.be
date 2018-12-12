#!/bin/bash

WORKDIR=$1
SRCDIR=${WORKDIR}/$1
JSONDIR=${WORKDIR}/report/json
PID=$$

( find ${SRCDIR} -name \*.jsonld -type f
; find ${JSONDIR} -name \*.jsonld -type f ) > /tmp/files.txt

pushd /app/pretty-print
 cat /tmp/files.txt | while read line
 do
     node pretty-print.js --input $line --output $line.out --descending "foaf:last_name" --descending "foaf:first_name"
     mv $line.out $line
 done
popd

