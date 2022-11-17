#!/bin/bash
#set -x

# Arg1 = the file containing the publication points to check their presence
# Arg2 = absolute directory where the content of the publication points are located on disk, no trailing slash expected
# Arg3 = set exit code hen error

FILE=$1
TARGETDIR=$2
EXITCODE=${3:-false}

TMPFILE=/tmp/tocheck.json
echo '0' > /tmp/checkexit

#echo "Checking ${FILE}"
echo "Directory check"

# test directory
jq --arg trg ${TARGETDIR} '[ .[] | $trg + .urlref ]' ${FILE} > ${TMPFILE}
jq --arg trg ${TARGETDIR} --arg ex ${EXITCODE} -r  '.[]  | @sh " if ! [ -d \(.) ] ; then  echo \"error: missing \(.)\" ; echo \"1\" > /tmp/checkexit ; fi" ' ${TMPFILE} | bash -e 

echo ""
echo "index.html check"

# test index.html in the directory 
# should have the same conclusion as above
jq --arg trg ${TARGETDIR} '[ .[] | $trg + .urlref + "/index.html" ]' ${FILE} > ${TMPFILE}
jq --arg trg ${TARGETDIR} --arg ex ${EXITCODE} -r  '.[]  | @sh " if ! [ -f \(.) ] ; then  echo \"error: missing \(.)\" ; echo '1' > /tmp/checkexit ; fi" ' ${TMPFILE} | bash -e 

echo ""
if [ ${EXITCODE} ] ; then
        exit $(cat /tmp/checkexit)
fi

