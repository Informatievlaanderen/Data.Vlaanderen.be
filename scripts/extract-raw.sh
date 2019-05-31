#!/bin/bash

set -x

extractwhat=$1
TARGETDIR=/tmp/workspace
CHECKOUTFILE=${TARGETDIR}/rawcheckouts.txt

#############################################################################################
# extraction command functions

get_mapping_file() {
    local MAPPINGFILE=`jq -r 'if (.filename | length) > 0 then .filename else @sh "config/eap-mapping.json"  end' .publication-point.json`
    #local MAPPINGFILE="config/eap-mapping.json"
    if [ -f ".names.txt" ]
    then
	STR=".[] | select(.name == \"$(cat .names.txt)\") | [.]"
	jq "${STR}" ${MAPPINGFILE} > .names.json
	MAPPINGFILE=".names.json"
    fi
    echo ${MAPPINGFILE}
}

#############################################################################################
# main one being worked on
copyall() {
    local MAPPINGFILE=$1
    local LINE=$2
    local RDIR=${TARGETDIR}/report
    local TTDIR=${TARGETDIR}/report/${LINE}
    mkdir -p ${RDIR} ${TTDIR} ${TARGETDIR}/target/${LINE}
    cp -vr .* ${TARGETDIR}/target/${LINE}
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
     	         raw) copyall $MAPPINGFILE $line
                      ;;
                   *) echo "ERROR: $extractwhat not defined"
        esac
      popd
    else
      echo "Error: ${SLINE}" >> log.txt
    fi
done

