#!/bin/bash

CONFIGDIR=$1
FILE=$2

GENERATEDORG=$(jq -r .generatedrepository.organisation ${CONFIGDIR}/config.json)
GENERATEDREPO=$(jq -r .generatedrepository.repository ${CONFIGDIR}/config.json)

jq --arg branchtag "${COMMIT}"  --arg org "${GENERATEDORG}" --arg repo "${GENERATEDREPO}" -r \
	' .[] |=  .original ' ${FILE}
