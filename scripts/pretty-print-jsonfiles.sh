#!/bin/bash

WORKDIR=$1
SRCDIR=${WORKDIR}/src
JSONDIR=${WORKDIR}/report/json
PID=$$

( find ${SRCDIR} -name \*.jsonld -type f ; find ${JSONDIR} -name \*.jsonld -type f ) > /tmp/files.txt

pushd /app/pretty-print
 cat /tmp/files.txt | while read line
 do
     echo "not yet working"
     echo node pretty-print.js --input $line --output $line.out "foaf:last_name" "foaf:first_name"     
     echo node pretty-print.js --input $line --output $line.out "foaf:last_name" "foaf:first_name"
     echo mv $line.out $line
 done
popd

