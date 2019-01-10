#!/bin/bash

set -x

TARGETDIR=/tmp/workspace
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

#############################################################################################
# extraction command functions

get_mapping_file() {
   if [ -f .names.json ] ; then
     echo ".names.json"
   else
     echo "no mapping file available" >> log.txt
     exit 1
   fi
}

#get_mapping_file() {
#    local MAPPINGFILE="config/eap-mapping.json"
#    if [ -f ".names.txt" ]
#    then
#	STR=".[] | select(.name == \"$(cat .names.txt)\") | [.]"
#	jq "${STR}" ${MAPPINGFILE} > .names.json
#	MAPPINGFILE=".names.json"
#    fi
#    echo ${MAPPINGFILE}
#}

#############################################################################################
copy_details() {
    local MAPPINGFILE=$1
    local SLINE=$2
    local TARGETDIR=$3

    mkdir -p $TARGETDIR
    $(cat .names.txt)

    SITE=`jq --arg sline ${SLINE} --arg tline ${TLINE} -r '.[0] |{"site" : .site, "sline": $sline, "tline": $tline} | @text "\(.sline)/\(.site)" ' < $1`

    if [ -d ${SITE} ] ; then
	    cp -r ${SITE}/* ${TARGETDIR}
    else 
	    echo "WARNING no site exists" >> log.txt
    fi
}

#############################################################################################

if [ ! -f "${CHECKOUTFILE}" ]
then
    # normalise the functioning
    echo $CWD > ${CHECKOUTFILE}
fi

cat ${CHECKOUTFILE} | while read line
do
    SLINE=${TARGETDIR}/src/${line}
    echo "Processing line ${SLINE}"
    if [ -d "${SLINE}" ]
    then
      pushd ${SLINE}
       MAPPINGFILE=$(get_mapping_file)   
       TDIR=${TARGETDIR}/target/${line}/html
       copy_details $MAPPINGFILE $SLINE $TARGETDIR
      popd
    else
      echo "Error: ${SLINE}" >> log.txt
    fi
done

