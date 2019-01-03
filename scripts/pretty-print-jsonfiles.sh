#!/bin/bash

WORKDIR=$1
SRCDIR=${WORKDIR}/src
JSONDIR=${WORKDIR}/json
PID=$$

( find ${SRCDIR} -name \*.jsonld -type f ; find ${JSONDIR} -name \*.jsonld -type f ) > /tmp/files.txt

pushd /app/pretty-print
 cat /tmp/files.txt | while read line
 do
     echo "node pretty-print.js --input $line --output $line.out"
     if ! node pretty-print.js --input $line --output $line.out
     then
	 echo "pretty print failed"
	 exit 1
     fi
     mv $line.out $line
 done
popd
