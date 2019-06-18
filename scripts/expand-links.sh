#!/bin/bash

LINKS=/tmp/workspace/links.txt
TARGET=/tmp/workspace/target

if [ -f $LINKS ] 
then

   mkdir -p ${TARGET} ${TARGET}/context ${TARGET}/shacl ${TARGET}/ns

   jq  --arg src ${TARGET} --arg tgt ${TARGET} -r '.[] | @sh "mkdir -p \($tgt)\(.urlref)"'  $LINKS | bash -e
   jq  --arg src ${TARGET} --arg tgt ${TARGET} -r '.[] | @sh "cp -r \($src)\(.seealso)/* \($tgt)\(.urlref)"'  $LINKS | bash -e
   jq  --arg src ${TARGET} --arg tgt ${TARGET}/context -r '.[] |if ( .urlref | startswith("/doc/applicatieprofiel") ) then  @sh "cp \($src)\(.seealso)/context/* \($tgt)" else empty end'  $LINKS | bash -e
   jq  --arg src ${TARGET} --arg tgt ${TARGET}/shacl -r '.[] | if ( .urlref | startswith("/doc/applicatieprofiel") ) then @sh "cp \($src)\(.seealso)/shacl/* \($tgt)" else empty end'  $LINKS | bash -e
#   jq  --arg src ${TARGET} --arg tgt ${TARGET} -r '.[] | if ( .urlref | startswith("/ns") ) then @text "cp \($src)\(.seealso)/html/* \($tgt)\(.urlref)" else empty end'  $LINKS | bash -e 
   jq  --arg src ${TARGET} --arg tgt ${TARGET}/ns -r '.[] | if ( .urlref | startswith("/ns") ) then if (.prefix ) then @sh "mkdir -p \($tgt)/\(.prefix)" else empty end else empty end'  $LINKS | bash -e 
   jq  --arg src ${TARGET} --arg tgt ${TARGET}/ns -r '.[] | if ( .urlref | startswith("/ns") ) then if (.prefix ) then @sh "cp \($src)\(.seealso)/voc/* \($tgt)/\(.prefix)" else @sh "cp \($src)\(.seealso)/voc/* \($tgt)" end else empty end'  $LINKS | bash -e 

 

fi
