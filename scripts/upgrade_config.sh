#!/bin/bash

TARGETDIR=$1
CONFIGDIR=$2
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

#
# convert older toolchain version configs to this version
#

upgrade_config() {
    local SLINE=$1
    echo "upgrade config for $LINE"

    PRIMELANGUAGE=$(jq .primeLanguage ${CONFIGDIR}/config.json)


    HASTRANSLATION=$(jq .[0].translation[0].language ${SLINE}/.names.json)
    echo "${HASTRANSLATION}"

    TITLE=$(jq .[0].title ${SLINE}/.names.json)
    TEMPLATE=$(jq .[0].template ${SLINE}/.names.json)
    NAME=$(jq .[0].name ${SLINE}/.names.json)

    TRANSLATIONOBJTEMPLATE='"{translation" : [{
       "language" : $jqlanguage,
       "title" : $jqtitle,
       "template" : $jqtemplate,
       "translationjson" : $jqtranslation,
       "mergefile" : $jqmergefile
     }]}'

    TRANSLATIONOBJ=$(jq -n \
	    --arg jqlanguage "${PRIMELANGUAGE} " --arg jqtitle "${TITLE}" --arg jqtemplate "${TEMPLATE}" \
	    --arg jqtranslation "${NAME}_${PRIMELANGUAGE}.json" --arg jqmergefile "${NAME}_${PRIMELANGUAGE}_merged.json" \
	    "${TRANSLATIONOBJTEMPLATE}")
    echo $TRANSLATIONOBJ > /tmp/upgrade.json

    jq -s '.[0][0] * .[1]' ${SLINE}/.names.json /tmp/upgrade.json > /tmp/mergedupgrade.json
    cat /tmp/mergedupgrade.json
#    cp /tmp/mergedupgrade.json > ${SLINE}/.names.json

        

}

echo "upgrade config: starting with $TARGETDIR $CONFIGDIR"

cat ${CHECKOUTFILE} | while read line; do
    SLINE=${TARGETDIR}/src/${line}
    TLINE=${TARGETDIR}/target/${line}
    RLINE=${TARGETDIR}/report/${line}
    TRLINE=${TARGETDIR}/translation/${line}
    if [ -d "${SLINE}" ]; then
        for i in ${SLINE}/*.jsonld; do
            echo "UPGRADE CONFIG: for file $i "
	    upgrade_config ${SLINE}
        done
    else
        echo "Error: ${SLINE}"
    fi
done
