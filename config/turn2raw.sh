#!/bin/bash

FILE=$1
COMMIT=$2

jq --arg branchtag "$COMMIT"  -r ' .[] |=  . + {"type": "raw"} + {"directory" : .urlref} + {"repository":"https://github.com/Informatievlaanderen/OSLO-Generated" } + {"branchtag" : "\($branchtag)" } ' ${FILE}
