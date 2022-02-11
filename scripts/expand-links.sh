#!/bin/bash

TARGETDIR=$1
CONFIGDIR=$2

STRICT=$(jq -r .toolchain.strickness ${CONFIGDIR}/config.json)
execution_strickness() {
	if [ "${STRICT}" != "lazy" ] ; then
		exit -1
	fi
}

LINKS=${TARGETDIR}/links.txt
TARGET=${TARGETDIR}/target

clean_links(){
	
        rm -f /tmp/cleanedlinks.txt
	echo "[]" > /tmp/cleanedlinks.txt
	jq -c '.[]' ${LINKS} | while read i; do
	SEEALSO=$(echo $i | jq -r '.seealso'  )
	if [ -d "${TARGET}${SEEALSO}" ] ; then
		jq ". + [$i]"  /tmp/cleanedlinks.txt > /tmp/cleanedlinks.txt1
		mv /tmp/cleanedlinks.txt1 /tmp/cleanedlinks.txt
	else
		echo "ERROR: ${TARGET}${SEEALSO} does not exist"
	fi		
        done
	cat /tmp/cleanedlinks.txt
	diff -q /tmp/cleanedlinks.txt ${LINKS}
}

cp_content_dir() {
	# copy the content of directory in a publication point into the target seealso directory
	local PUBLICATIONPOINT=$1
	local FROM=$2
	local TO=$3

	SEEALSO=$(echo ${PUBLICATIONPOINT} | jq -r '.seealso'  )
	if [ -d "${TARGET}${SEEALSO}/${FROM}" ] ; then
		cp ${TARGET}${SEEALSO}/${FROM}/* ${TARGET}/${TO}
	else
		echo "ERROR: expected subdirectory ${TARGET}${SEEALSO}/${FROM} does not exist"
	fi		

}

if [ -f ${LINKS} ] 
then

   clean_links
   LINKS=/tmp/cleanedlinks.txt
   mkdir -p ${TARGET} ${TARGET}/context ${TARGET}/shacl ${TARGET}/ns

   jq  --arg src ${TARGET} --arg tgt ${TARGET} -r '.[] | @sh "mkdir -p \($tgt)\(.urlref)"'  $LINKS | bash -e
   jq  --arg src ${TARGET} --arg tgt ${TARGET} -r '.[] | @sh "cp -r \($src)\(.seealso)/* \($tgt)\(.urlref)"'  $LINKS | bash -e

   jq -c '.[]' ${LINKS} | while read i; do
   
	TARGETSPEC=$(echo ${i} | jq -r '.urlref | startswith("/doc/applicatieprofiel") '  )
	if [ ${TARGETSPEC} == "true" ] ; then
	   cp_content_dir $i context context
	   cp_content_dir $i shacl shacl
	fi
	TARGETSPEC=$(echo ${i} | jq -r '.urlref | startswith("/ns") '  )
	if [ ${TARGETSPEC} == "true" ] ; then
   	   jq  --arg src ${TARGET} --arg tgt ${TARGET}/ns -r '.[] | if ( .urlref | startswith("/ns") ) then if (.prefix ) then @sh "mkdir -p \($tgt)/\(.prefix)" else empty end else empty end'  $LINKS | bash -e 
	   PREFIX=$(echo ${i} | jq -r '.prefix | values'  )
	   cp_content_dir $i voc ns/${PREFIX}
	fi


   done

#   jq  --arg src ${TARGET} --arg tgt ${TARGET}/context -r '.[] |if ( .urlref | startswith("/doc/applicatieprofiel") ) then  @sh "cp \($src)\(.seealso)/context/* \($tgt)" else empty end'  $LINKS | bash -e
#   jq  --arg src ${TARGET} --arg tgt ${TARGET}/shacl -r '.[] | if ( .urlref | startswith("/doc/applicatieprofiel") ) then @sh "cp \($src)\(.seealso)/shacl/* \($tgt)" else empty end'  $LINKS | bash -e
##   jq  --arg src ${TARGET} --arg tgt ${TARGET} -r '.[] | if ( .urlref | startswith("/ns") ) then @text "cp \($src)\(.seealso)/html/* \($tgt)\(.urlref)" else empty end'  $LINKS | bash -e 
#   jq  --arg src ${TARGET} --arg tgt ${TARGET}/ns -r '.[] | if ( .urlref | startswith("/ns") ) then if (.prefix ) then @sh "mkdir -p \($tgt)/\(.prefix)" else empty end else empty end'  $LINKS | bash -e 
#   jq  --arg src ${TARGET} --arg tgt ${TARGET}/ns -r '.[] | if ( .urlref | startswith("/ns") ) then if (.prefix ) then @sh "cp \($src)\(.seealso)/voc/* \($tgt)/\(.prefix)" else @sh "cp \($src)\(.seealso)/voc/* \($tgt)" end else empty end'  $LINKS | bash -e 


fi
