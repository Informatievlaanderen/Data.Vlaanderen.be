#!/bin/bash

WORKDIR=$1
DIRS="${WORKDIR}/src ${WORKDIR}/json ${WORKDIR}/report"
PID=$$


rm -rf /tmp/files.txt
for i in ${DIRS} ; do
( find ${i} -name \*.jsonld -type f) >> /tmp/files.txt
done


pushd /app
 cat /tmp/files.txt | while read line
 do
     echo "node pretty-print.js --input $line --output $line.out"
     if ! node pretty-print.js --input $line --output $line.out1
     then
	 echo "pretty print failed"
	 exit 1
     fi
     if ! node pretty-print.js --input $line.out1 --output $line.out -s properties externalproperties -a '@id' 'name' 'definition' 
     then
	 echo "pretty print failed"
	 exit 1
     fi
     mv $line.out $line
     rm $line.out1
 done
popd
