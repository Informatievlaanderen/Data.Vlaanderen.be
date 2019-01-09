#!/bin/bash

set -x

extractwhat=$1
TARGETDIR=/tmp/workspace
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

#############################################################################################
# extraction command functions

get_mapping_file() {
    local MAPPINGFILE="config/eap-mapping.json"
    if [ -f ".names.txt" ]
    then
	STR=".[] | select(.name == \"$(cat .names.txt)\") | [.]"
	jq "${STR}" ${MAPPINGFILE} > .names.json
	MAPPINGFILE=".names.json"
    fi
    echo ${MAPPINGFILE}
}

#############################################################################################
extract_tsv() {
    local MAPPINGFILE=$1
    local LINE=$2
    local TDIR=${TARGETDIR}/report/${LINE}/tsv
    mkdir -p ${TDIR} ${TARGETDIR}/tsv
    
    # Extract tsv data for each diagram    
    #jq -r '.[] | select(.type | contains("ap")) | @sh "java -jar /app/ea-2-rdf.jar tsv -i \(.eap) -c config/config-ap.json -d \(.diagram) -o /tmp/workspace/tsv/\(if .prefix then .prefix + "/" else "" end)\(.name).tsv"' < $MAPPINGFILE | bash -e
    jq -r '.[] | @sh "java -jar /app/ea-2-rdf.jar tsv -i \(.eap) -c \(.config) -d \(.diagram) -o /tmp/workspace/tsv/\(if .prefix then .prefix + "/" else "" end)\(.name).tsv"' < $MAPPINGFILE | bash -e

#    if [ ! -f "$(cat .names.txt).tsv" ]
#    then
#	echo "extract_what(tsv): $(cat .names.txt).tsv was not created"
#	exit -1;
#    fi
    cp $(cat .names.txt).tsv ${TDIR}
    cp /tmp/workspace/tsv/$(cat .names.txt).tsv ${TDIR}    
}

#############################################################################################
extract_raw() {
    local MAPPINGFILE=$1
    local LINE=$2
    local TDIR=${TARGETDIR}/report/${LINE}/raw
    mkdir -p ${TDIR} ${TARGETDIR}/raw
    
    # Extract tsv data for each diagram    
    #jq -r '.[] | select(.type | contains("ap")) | @sh "java -jar /app/ea-2-rdf.jar tsv -i \(.eap) -c config/config-ap.json -d \(.diagram) -o /tmp/workspace/tsv/\(if .prefix then .prefix + "/" else "" end)\(.name).tsv"' < $MAPPINGFILE | bash -e
    jq -r '.[] | @sh "java -jar /app/ea-2-rdf.jar list -i \(.eap) --full --format json > /tmp/workspace/raw/\(.name).raw"' < $MAPPINGFILE | bash -e

#    if [ ! -f "$(cat .names.txt).tsv" ]
#    then
#	echo "extract_what(tsv): $(cat .names.txt).tsv was not created"
#	exit -1;
#    fi
    cp /tmp/workspace/raw/$(cat .names.txt).raw ${TDIR}    
}
#############################################################################################
extract_ttl() {
    local MAPPINGFILE=$1
    local TDIR=${TARGETDIR}/ttl
    mkdir -p ${TDIR}
    # Extract ttl data for each diagram
    jq -r '.[] | select(.type | contains("voc")) | @sh "java -jar /app/ea-2-rdf.jar convert -i \(.eap) -c config/config-voc.json -d \(.diagram) -o /tmp/workspace/ttl/\(if .prefix then .prefix + "/" else "" end)\(.name).ttl"' $MAPPINGFILE | bash -e
}

#############################################################################################
extract_stakeholder() {
    local MAPPINGFILE=$1
    local TDIR=${TARGETDIR}/ttl
    mkdir -p ${TDIR}
    jq -r '.[] | select(.type | contains("voc")) | @sh "python /app/specgen/generate_vocabulary.py --add_contributors --rdf /tmp/workspace/ttl/\(if .prefix then .prefix + "/" else "" end)\(.name).ttl --csv src/stakeholders.csv --csv_contributor_role_column \(.contributors) --output /tmp/workspace/ttl/\(if .prefix then .prefix + "/" else "" end)\(.name).ttl"' < $MAPPINGFILE | bash -e
}

#############################################################################################
# main one being worked on
extract_json() {
    local MAPPINGFILE=$1
    cat $MAPPINGFILE
    local LINE=$2
    local TDIR=${TARGETDIR}/json
    local RDIR=${TARGETDIR}/report
    local TTDIR=${TARGETDIR}/report/${LINE}
    mkdir -p ${TDIR} ${RDIR} ${TTDIR} ${TARGETDIR}/target/${LINE}
    java -jar /app/ea-2-rdf.jar jsonld -c ${MAPPINGFILE} -n $(cat .names.txt) &> $(cat .names.txt).report
    if [ ! -f "$(cat .names.txt).jsonld" ]
    then
	echo "extract_json: $(cat .names.txt).jsonld was not created"
	exit -1;
    fi
    cat .publication-point.json
    jq -s '.[0] + .[1][0] + .[2]' $(cat .names.txt).jsonld $MAPPINGFILE .publication-point.json > ${TTDIR}/all-$(cat .names.txt).jsonld
    cp $(cat .names.txt).jsonld ${TDIR}    
    cp $(cat .names.txt).jsonld ${TTDIR}
    cp $(cat .names.txt).report ${RDIR}
    ( echo $PWD ; cat $(cat .names.txt).report ) >> ${RDIR}/ALL.report
}

# do the conversions

if [ ! -f "${CHECKOUTFILE}" ]
then
    # normalise the functioning
    echo $CWD > ${CHECKOUTFILE}
fi

cat ${CHECKOUTFILE} | while read line
do
    SLINE=${TARGETDIR}/src/${line}
    echo "Processing line ($extractwhat): ${SLINE}"
    if [ -d "${SLINE}" ]
    then
      pushd ${SLINE}
       MAPPINGFILE=$(get_mapping_file)   
       cat $MAPPINGFILE
       case $extractwhat in
     	         raw) extract_raw $MAPPINGFILE $line
                      ;;
     	         tsv) extract_tsv $MAPPINGFILE $line
		      ;;
                 ttl) extract_ttl $MAPPINGFILE 
		      ;;
	      jsonld) extract_json $MAPPINGFILE $line
		      ;;
        stakeholders) extract_stakeholder $MAPPINGFILE
		      ;;
                   *) echo "ERROR: $extractwhat not defined"
        esac
      popd
    else
      echo "Error: ${SLINE}" >> log.txt
    fi
done

