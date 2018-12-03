#!/bin/bash

set -x

extractwhat=$1
CHECKOUTFILE=/tmp/workspace/checkouts.txt

# extraction commands

extract_tsv() {
    jq -r '.[] | select(.type | contains("ap")) | @sh "java -jar /app/ea-2-rdf.jar tsv -i src/\(.eap) -c config/config-ap.json -d \(.diagram) -o /tmp/workspace/tsv/\(if .prefix then .prefix + "/" else "" end)\(.name).tsv"' < config/eap-mapping.json | bash
}

# do the conversions

if [ ! -f "${CHECKOUTFILE}" ]
then
    # normalise the functioning
    echo $CWD > ${CHECKOUTFILE}
fi

cat ${CHECKOUTFILE} | while read line
do
    echo "Processing line: $line"
    if [ -d "$line" ]
    then
      pushd $line
        case $extractwhat in
     	    tsv) extract_tsv >> log.txt
		 ;;
              *) echo "towhat not defined"
        esac 	   
      popd
    else
      echo "Error: $line" >> log.txt
    fi
done
