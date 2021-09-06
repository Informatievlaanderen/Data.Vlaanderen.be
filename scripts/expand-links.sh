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
	
        rm /tmp/cleanedlinks.txt
	echo "[]" > /tmp/cleanedlinks.txt
	jq -c '.[]' ${LINKS} | while read i; do
	SEEALSO=$(jq .seealso $i)
	if [ -d "${TARGET}${SEEALSO}" ] ; then
		jq . += $i /tmp/cleanedlinks.txt
	fi		
        done
	cat /tmp/cleanedlinks.txt
	diff -q /tmp/cleanedlinks.txt ${LINKS}
}

if [ -f $LINKS ] 
then

   clean_links
   mkdir -p ${TARGET} ${TARGET}/context ${TARGET}/shacl ${TARGET}/ns

   jq  --arg src ${TARGET} --arg tgt ${TARGET} -r '.[] | @sh "mkdir -p \($tgt)\(.urlref)"'  $LINKS | bash -e
   jq  --arg src ${TARGET} --arg tgt ${TARGET} -r '.[] | @sh "cp -r \($src)\(.seealso)/* \($tgt)\(.urlref)"'  $LINKS | bash -e
   jq  --arg src ${TARGET} --arg tgt ${TARGET}/context -r '.[] |if ( .urlref | startswith("/doc/applicatieprofiel") ) then  @sh "cp \($src)\(.seealso)/context/* \($tgt)" else empty end'  $LINKS | bash -e
   jq  --arg src ${TARGET} --arg tgt ${TARGET}/shacl -r '.[] | if ( .urlref | startswith("/doc/applicatieprofiel") ) then @sh "cp \($src)\(.seealso)/shacl/* \($tgt)" else empty end'  $LINKS | bash -e
#   jq  --arg src ${TARGET} --arg tgt ${TARGET} -r '.[] | if ( .urlref | startswith("/ns") ) then @text "cp \($src)\(.seealso)/html/* \($tgt)\(.urlref)" else empty end'  $LINKS | bash -e 
   jq  --arg src ${TARGET} --arg tgt ${TARGET}/ns -r '.[] | if ( .urlref | startswith("/ns") ) then if (.prefix ) then @sh "mkdir -p \($tgt)/\(.prefix)" else empty end else empty end'  $LINKS | bash -e 
   jq  --arg src ${TARGET} --arg tgt ${TARGET}/ns -r '.[] | if ( .urlref | startswith("/ns") ) then if (.prefix ) then @sh "cp \($src)\(.seealso)/voc/* \($tgt)/\(.prefix)" else @sh "cp \($src)\(.seealso)/voc/* \($tgt)" end else empty end'  $LINKS | bash -e 


fi
