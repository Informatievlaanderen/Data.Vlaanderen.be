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
    local LINE=$1
    local RDIR=${TARGETDIR}/report
    local TTDIR=${TARGETDIR}/report/${LINE}
    mkdir -p ${RDIR} ${TTDIR} ${TARGETDIR}/raw/${LINE} ${TARGETDIR}/raw/report/${LINE}
    cp -vr ${TARGETDIR}/raw-input/${LINE}/* ${TARGETDIR}/raw/${LINE}
    if [ -d ${TARGETDIR}/raw-input/report/${LINE} ]
    then
        cp -vr ${TARGETDIR}/raw-input/report/${LINE}/* ${TARGETDIR}/raw/report/${LINE}
    fi
}

# do the conversions

if [ ! -f "${CHECKOUTFILE}" ]
then
    # normalise the functioning
    echo $CWD > ${CHECKOUTFILE}
fi

cat ${CHECKOUTFILE} | while read line
do
    if [[ $line =~ "doc" ]]  ; then
    # expect a line with doc into it
    SLINE=${TARGETDIR}/raw-input/${line}
    echo "Processing line ($extractwhat): ${SLINE}"
    if [ -d "${SLINE}" ]
    then
      pushd ${SLINE}

       case $extractwhat in
     	         raw) copyall $line
                      ;;
                   *) echo "ERROR: $extractwhat not defined"
        esac
      popd
    else
      echo "Error: ${SLINE}" >> log.txt
    fi
    fi
done

