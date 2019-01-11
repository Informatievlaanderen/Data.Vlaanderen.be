#!/bin/bash

LINKS=/tmp/workspace/links.txt
TARGET=/tmp/workspace/target

if [ -f $LINKS ] 
then
#   prerequisite
#   mv all /html/*.html  to index.html as file 
#   that makes the copying more trival. also we have to check in taht case there is only one html produced per document...

   jq  --arg src ${TARGET} --arg tgt ${TARGET} -r '.[] | @sh "cp -r \($src)\(.seealso)/* \($tgt)\(.urlref)"'  $LINKS | bash -e
   jq  --arg src ${TARGET} --arg tgt ${TARGET}/context -r '.[] | @sh "cp \($src)\(.seealso)/context/* \($tgt)"'  $LINKS | bash -e
   jq  --arg src ${TARGET} --arg tgt ${TARGET}/shacl -r '.[] | if ( .urlref | startswith("/doc/applicatieprofiel") ) then @sh "cp \($src)\(.seealso)/shacl/* \($tgt)" else empty end'  $LINKS | bash -e
#   jq  --arg src ${TARGET} --arg tgt ${TARGET} -r '.[] | if ( .urlref | startswith("/ns") ) then @text "cp \($src)\(.seealso)/html/* \($tgt)\(.urlref)" else empty end'  $LINKS | bash -e 
   jq  --arg src ${TARGET} --arg tgt ${TARGET}/ns -r '.[] | if ( .urlref | startswith("/ns") ) then @sh "cp \($src)\(.seealso)/voc/* \($tgt)" else empty end'  $LINKS | bash -e 


fi
