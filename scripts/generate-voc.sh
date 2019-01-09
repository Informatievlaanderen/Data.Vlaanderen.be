#!/bin/bash

TARGETDIR=$1
SUBDIR=$2
CONFIGDIR=$3
CHECKOUTFILE=${TARGETDIR}/checkouts.txt

echo "generate-voc: starting with $1 $2 $3"

#############################################################################################
make_jsonld() {
    local FILE=$1 
    local INPUT=$2
    local TARGET=$3
    local CONFIGDIR=$4
    mkdir -p /tmp/${FILE}
    jq 'walk( if type == "object" and (.range | length) > 0 then .range |= map(.uri)  else . end)' ${INPUT} > /tmp/${FILE}0.jsonld
    jq 'walk( if type == "object" and (.domain | length) > 0 then .domain |= map(.uri)  else . end)' /tmp/${FILE}0.jsonld > /tmp/${FILE}1.jsonld
    jq 'walk( if type == "object" and (.nl | length) > 0 and (.nl | sub(" ";"";"g") | length) == 0 then .nl |= ""  else . end)' /tmp/${FILE}1.jsonld > /tmp/${FILE}2.jsonld
    jq 'walk( if type == "object" and (.usage| type) == "object" and (.usage.nl | length) == 0 then .usage |= {}  else . end)' /tmp/${FILE}2.jsonld > /tmp/${FILE}3.jsonld

    jq -S '.classes| map({"name" : .name, "description" : .description , "usage" : .usage, "@id" : ."@id", "@type" : ."@type", "parents" : .parents? }) |sort_by(."@id")' /tmp/${FILE}3.jsonld > /tmp/${FILE}/classes
    jq -S '.externals| map({"name" : .name,  "@id" : ."@id", "@type" : "rdfs:Class" } ) |sort_by(."@id")' /tmp/${FILE}3.jsonld > /tmp/${FILE}/externalclasses
    jq -S '.properties| map({"name" : .name, "description" : .description , "usage" : .usage, "@id" : ."@id", "@type" : ."@type", "domain" : .domain, "range" : .range } )| sort_by(."@id")' /tmp/${FILE}3.jsonld > /tmp/${FILE}/properties
    jq -S '.externalproperties| map({"name" : .name,  "@id" : ."@id", "@type" : "rdf:Property" } ) | sort_by(."@id")' /tmp/${FILE}3.jsonld > /tmp/${FILE}/externalproperties
    jq -S '{"@id" : ."@id", "@type" : ."@type", "label": .label, "title": .title?, "namespace": .namespace?, "authors" : .authors, "editors" : .editors, "contributors" : .contributors, "publication-state" : ."publication-state"?, "publication-date" : ."publication-date"?, "navigation" : .navigation?}' /tmp/${FILE}3.jsonld > /tmp/${FILE}/ontology

    jq -s '.[0] + .[1] + {"classes": .[2], "properties": .[4], "externals": .[3], "externalproperties": .[5]} + .[6]' /tmp/${FILE}/ontology ${CONFIGDIR}/ontology.defaults.json /tmp/${FILE}/classes /tmp/${FILE}/externalclasses /tmp/${FILE}/properties /tmp/${FILE}/externalproperties ${CONFIGDIR}/context >  ${TARGET}
}
#############################################################################################

mkdir -p ${TARGETDIR}/html

cat ${CHECKOUTFILE} | while read line
do
    SLINE=${TARGETDIR}/src/${line}
    TLINE=${TARGETDIR}/target/${line} 
    RLINE=${TARGETDIR}/report/${line}   
    echo "Processing line: ${SLINE} => ${TLINE} ${RLINE}"
    if [ -d "${SLINE}" ]
    then
            for i in ${SLINE}/*.jsonld
            do
                echo "generate-voc: convert $i to RDF"
                BASENAME=$(basename $i .jsonld)
                OUTFILE=${BASENAME}.ttl
                REPORT=${RLINE}/${BASENAME}.ttl-report

                mkdir -p ${TLINE}/voc
                make_jsonld $BASENAME $i ${SLINE}/selected.jsonld ${CONFIGDIR} || exit 1
                if ! rdf serialize --input-format jsonld --processingMode json-ld-1.1 ${SLINE}/selected.jsonld --output-format turtle -o ${TLINE}/voc/$BASENAME.ttl 2>&1 | tee ${REPORT}
                then
                    exit 1
                fi
            done
    else
	    echo "Error: ${SLINE}"
    fi
done



