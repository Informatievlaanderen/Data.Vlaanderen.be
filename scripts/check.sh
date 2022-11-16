#!/bin/bash

# Arg1 = the file containg the publication points to check their presence
# Arg2 = absolute directory where the content of the publication points are located on disk, no trailing slash expected

FILE=$1
TARGETDIR=$2

TMPFILE=/tmp/tocheck.json


echo "Directory check"

# test directory
jq --arg trg ${TARGETDIR} '[ .[] | $trg + .urlref ]' ${FILE} > ${TMPFILE}
jq --arg trg ${TARGETDIR} -r  '.[]  | @sh " if ! [ -d \(.) ] ; then  echo \"error: missing \(.)\" ;  fi" ' ${TMPFILE} | bash -e 

echo ""
echo "index.html check"

# test index.html in the directory 
# should have the same conclusion as above
jq --arg trg ${TARGETDIR} '[ .[] | $trg + .urlref + "/index.html" ]' ${FILE} > ${TMPFILE}
jq --arg trg ${TARGETDIR} -r  '.[]  | @sh " if ! [ -f \(.) ] ; then echo \"error: missing \(.)\" ;  fi" ' ${TMPFILE} | bash -e 

