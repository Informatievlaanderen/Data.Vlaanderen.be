#!/bin/bash


INPUT=$1
OUTPUTDIR=$2
OUTPUTFILE=$3

OUTPUT=${OUTPUTDIR}${OUTPUTFILE}
RESULT=stat.template

mkdir -p ${OUTPUTDIR}

jq '[ .classes[] | .["@id"] ]' ${INPUT} > ${OUTPUT}.class
jq '[.properties[]| .["@id"]]' ${INPUT} > ${OUTPUT}.props
jq '[.externals[]| .["@id"]]' ${INPUT} > ${OUTPUT}.extclass
jq '[.externalproperties[]| .["@id"]]' ${INPUT} > ${OUTPUT}.extprops


NBCLASSES=`jq 'unique | length ' ${OUTPUT}.class`
NBEXTCLASSES=`jq 'unique | length ' ${OUTPUT}.extclass`
NBPROPERTIES=`jq 'unique |length '  ${OUTPUT}.props`
NBEXTPROPERTIES=`jq 'unique | length '  ${OUTPUT}.extprops`

NBTOTALTERMS=`jq -s '.[0] + .[1] + .[2] + .[3]  | unique | length' ${OUTPUT}.class ${OUTPUT}.extclass ${OUTPUT}.props ${OUTPUT}.extprops`

jq '.authors' ${INPUT} > ${OUTPUT}.authors.0
jq '.editors' ${INPUT} > ${OUTPUT}.editors.0
jq '.contributors' ${INPUT} > ${OUTPUT}.contributors.0

cleanorgs () {
	local finput=$1
	local fext=$2
	jq ' [.[] | .aff = .affiliation."foaf:name" | .name = ."foaf:firstName" + . "foaf:lastName" ]' ${finput}.${fext}.0 > ${finput}.o.2
	jq ' [ .[] | {"affiliation" : .aff , "name" : .name | ascii_downcase } ] ' ${finput}.o.2 > ${finput}.o.3
	sed  "s/\s//g" ${finput}.o.3 > ${finput}.${fext}
	rm ${finput}.o.*
}

cleanorgs ${OUTPUT} authors
cleanorgs ${OUTPUT} editors 
cleanorgs ${OUTPUT} contributors


NBAUTHORS=`jq 'length' ${OUTPUT}.authors `
NBEDITORS=`jq 'length' ${OUTPUT}.editors `
NBCONTRIBUTORS=`jq 'length' ${OUTPUT}.contributors`

jq ' .authors + .editors + .contributors  | unique ' ${INPUT} > ${OUTPUT}.org
jq ' [.[] | .aff = .affiliation."foaf:name" | .name = ."foaf:firstName" + . "foaf:lastName" ]' ${OUTPUT}.org > $OUTPUT.org2
jq ' [ .[] | {"affiliation" : .aff , "name" : .name | ascii_downcase } ] ' ${OUTPUT}.org2 > ${OUTPUT}.org3
sed  "s/\s//g" ${OUTPUT}.org3 > ${OUTPUT}.org4
jq ' group_by(.affiliation) ' ${OUTPUT}.org4 > ${OUTPUT}.org5

jq ' [ .[] | { "affiliation" : .[0].affiliation , "participants": length } ] ' ${OUTPUT}.org5 > ${OUTPUT}.org6 
NBTOTALORGANISATIONS=`jq 'length' ${OUTPUT}.org6`

rm ${OUTPUT}.org 
rm ${OUTPUT}.org2 
rm ${OUTPUT}.org3 
rm ${OUTPUT}.org5 



cp ${RESULT} ${RESULT}.0

jq '{"status" : ."publication-state" , "date" : ."publication-date", "specification": .urlref } ' ${INPUT} > ${RESULT}.in
jq -s ".[0]+ .[1]" ${RESULT}.in ${RESULT} > ${RESULT}.0

jq ".authors = $NBAUTHORS"             ${RESULT}.0 > ${RESULT}.1
jq ".editors = $NBEDITORS"             ${RESULT}.1 > ${RESULT}.2
jq ".contributors = $NBCONTRIBUTORS"   ${RESULT}.2 > ${RESULT}.3
jq ".classes = $NBCLASSES"             ${RESULT}.3 > ${RESULT}.4
jq ".externalclasses = $NBEXTCLASSES"  ${RESULT}.4 > ${RESULT}.5
jq ".properties = $NBPROPERTIES"       ${RESULT}.5 > ${RESULT}.6
jq ".externalproperties = $NBEXTPROPERTIES" ${RESULT}.6 > ${RESULT}.7
jq ".totalterms = $NBTOTALTERMS "      ${RESULT}.7 > ${RESULT}.8
jq ".totalorganisations = $NBTOTALORGANISATIONS"      ${RESULT}.8 > ${RESULT}.9
jq -s ".[0].organisations = .[1] | .[0] " ${RESULT}.9  ${OUTPUT}.org6 > ${RESULT}.10

cp ${RESULT}.10 ${OUTPUT}
rm ${RESULT}.*


