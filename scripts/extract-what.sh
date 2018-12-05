#!/bin/bash

set -x

extractwhat=$1
TARGETDIR=/tmp/workspace
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

#############################################################################################
# extraction command functions

extract_tsv() {
    local TDIR=${TARGETDIR}/tsv
    mkdir -p ${TDIR}
    # Extract tsv data for each diagram    
    jq -r '.[] | select(.type | contains("ap")) | @sh "java -jar /app/ea-2-rdf.jar tsv -i \(.eap) -c config/config-ap.json -d \(.diagram) -o ${TDIR}/\(if .prefix then .prefix + "/" else "" end)\(.name).tsv"' < config/eap-mapping.json | bash
}

extract_ttl() {
    local TDIR=${TARGETDIR}/ttl
    mkdir -p ${TDIR}
    # Extract ttl data for each diagram
    local MAPPINGFILE="config/eap-mapping.json"
    if [ -f ".names.txt" ]
    then
	echo "name: $(cat .names.txt)"
	STR=".[] | select(.name | contains(\"$(cat .names.txt)\")) | [.]"
	jq "${STR}" ${MAPPINGFILE} > .names.json
	MAPPINGFILE=".names.json"
    fi
    jq -r '.[] | select(.type | contains("voc")) | @sh "java -jar /app/ea-2-rdf.jar convert -i \(.eap) -c config/config-voc.json -d \(.diagram) -o ${TDIR}/\(if .prefix then .prefix + "/" else "" end)\(.name).ttl"' $MAPPINGFILE | bash
}

# do the conversions

if [ ! -f "${CHECKOUTFILE}" ]
then
    # normalise the functioning
    echo $CWD > ${CHECKOUTFILE}
fi

cat ${CHECKOUTFILE} | while read line
do
    echo "Processing line ($extractwhat): $line"
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
