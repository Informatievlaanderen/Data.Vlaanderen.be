#!/bin/bash

set -x

extractwhat=$1
TARGETDIR=/tmp/workspace
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

#############################################################################################
# extraction command functions

mappings_file() {
    local MAPPINGFILE="config/eap-mapping.json"
    if [ -f ".names.txt" ]
    then
	STR=".[] | select(.name | contains(\"$(cat .names.txt)\")) | [.]"
	jq "${STR}" ${MAPPINGFILE} > .names.json
	MAPPINGFILE=".names.json"
    fi
    echo ${MAPPINGFILE}
}

extract_tsv() {
    local MAPPINGFILE=$1
    local TDIR=${TARGETDIR}/tsv
    mkdir -p ${TDIR}
    # Extract tsv data for each diagram    
    jq -r '.[] | select(.type | contains("ap")) | @sh "java -jar /app/ea-2-rdf.jar tsv -i \(.eap) -c config/config-ap.json -d \(.diagram) -o /tmp/workspace/tsv/\(if .prefix then .prefix + "/" else "" end)\(.name).tsv"' < $MAPPINGFILE | bash
}

extract_ttl() {
    local MAPPINGFILE=$1
    local TDIR=${TARGETDIR}/ttl
    mkdir -p ${TDIR}
    # Extract ttl data for each diagram
    jq -r '.[] | select(.type | contains("voc")) | @sh "java -jar /app/ea-2-rdf.jar convert -i \(.eap) -c config/config-voc.json -d \(.diagram) -o /tmp/workspace/ttl/\(if .prefix then .prefix + "/" else "" end)\(.name).ttl"' $MAPPINGFILE | bash
}

extract_stakeholder() {
    local MAPPINGFILE=$1
    local TDIR=${TARGETDIR}/ttl
    mkdir -p ${TDIR}
    jq -r '.[] | select(.type | contains("voc")) | @sh "python /app/specgen/generate_vocabulary.py --add_contributors --rdf /tmp/workspace/ttl/\(if .prefix then .prefix + "/" else "" end)\(.name).ttl --csv src/stakeholders.csv --csv_contributor_role_column \(.contributors) --output /tmp/workspace/ttl/\(if .prefix then .prefix + "/" else "" end)\(.name).ttl"' < $MAPPINGFILE | bash
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
       local MAPPINGFILE=$(mapping_file)    
       case $extractwhat in
     	         tsv) extract_tsv $MAPPINGFILE
		      ;;
                 ttl) extract_ttl $MAPPINGFILE
		      ;;
        stakeholders) extract_stakeholder $MAPPINGFILE
		      ;;
                   *) echo "ERROR: $extractwhat not defined"
        esac 	   
      popd
    else
      echo "Error: $line" >> log.txt
    fi
done

