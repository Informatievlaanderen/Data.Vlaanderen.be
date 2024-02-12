#!/bin/bash

CONFIGDIR=$1
FILE=$2
COMMIT=$3

GENERATEDORG=$(jq -r .generatedrepository.organisation ${CONFIGDIR}/config.json)
GENERATEDREPO=$(jq -r .generatedrepository.repository ${CONFIGDIR}/config.json)

jq --arg branchtag "${COMMIT}"  --arg org "${GENERATEDORG}" --arg repo "${GENERATEDREPO}" -r \
	' .[] |=  . + {"type": "raw"} + {"directory" : .urlref} + {"repository":"https://github.com/\($org)/\($repo)" } + {"branchtag" : "\($branchtag)" } + {"original" : . }' ${FILE}
