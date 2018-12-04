#!/bin/bash

set -x

extractwhat=$1
CHECKOUTFILE=/tmp/workspace/checkouts.txt

# extraction commands

extract_tsv() {
    # Extract tsv data for each diagram    
    jq -r '.[] | select(.type | contains("ap")) | @sh "java -jar /app/ea-2-rdf.jar tsv -i \(.eap) -c config/config-ap.json -d \(.diagram) -o /tmp/workspace/tsv/\(if .prefix then .prefix + "/" else "" end)\(.name).tsv"' < config/eap-mapping.json | bash
}

extract_ttl() {
    # Extract ttl data for each diagram
    local MAPPINGFILE="config/eap-mapping.json"
    if [ -f ".names.txt" ]
    then
	echo "name: $(cat .names.txt)"
	STR="'.[] | select(.name | contains(\"$(cat .names.txt)\"))'"
	jq -r "${STR}" ${MAPPINGFILE} > .names.json
	MAPPINGFILE=".names.json"
    fi
    jq -r '.[] | select(.type | contains("voc")) | @sh "java -jar /app/ea-2-rdf.jar convert -i \(.eap) -c config/config-voc.json -d \(.diagram) -o /tmp/workspace/ttl/\(if .prefix then .prefix + "/" else "" end)\(.name).ttl"' $MAPPINGFILE | bash
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
     	    tsv) extract_tsv
		 ;;
     	    ttl) extract_ttl
		 ;;
              *) echo "towhat not defined"
        esac 	   
      popd
    else
      echo "Error: $line" >> log.txt
    fi
done
