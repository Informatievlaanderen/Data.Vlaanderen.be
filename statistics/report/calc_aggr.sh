#!/bin/bash

INPUT=$1
INPUT1=$1.organisations
INPUT2=$1.class
INPUT3=$1.props
INPUT4=$1.extclass
INPUT5=$1.extprops
OUTPUT=$2
RESULT=aggr.template


# calculate the participants

NBAUTHORS=`jq 'unique | length' ${INPUT}.authors `
NBEDITORS=`jq 'unique | length' ${INPUT}.editors `
NBCONTRIBUTORS=`jq 'unique | length' ${INPUT}.contributors`

NBPARTICIPANTS=`jq -s '.[0] + .[1] + .[2] + .[3]  | unique | length' ${INPUT}.authors ${INPUT}.editors ${INPUT}.contributors`

# calculate the terms

NBCLASSES=`jq 'unique | length ' ${INPUT2}`
NBEXTCLASSES=`jq 'unique | length ' ${INPUT4}`
NBPROPERTIES=`jq 'unique |length '  ${INPUT3}`
NBEXTPROPERTIES=`jq 'unique | length '  ${INPUT5}`

NBTOTALTERMS=`jq -s '.[0] + .[1] + .[2] + .[3]  | unique | length' ${INPUT2} ${INPUT3} ${INPUT4} ${INPUT5}`


# calculate the organisations

#jq . ${INPUT1} > ${OUTPUT}.input

jq ' group_by(.affiliation) ' ${INPUT1} > ${OUTPUT}.org.1

jq ' [ .[] | { "affiliation" : .[0].affiliation , "participants": length } ] ' ${OUTPUT}.org.1 > ${OUTPUT}.org.2 
NBTOTALORGANISATIONS=`jq 'length' ${OUTPUT}.org.2`

rm ${OUTPUT}.org.1


# calculate the specs
jq 'group_by( .status ) ' ${INPUT}.specstats > ${INPUT}.specstats.1
jq ' [ .[] | { "status" : .[0].status, "specifications": length } ] ' ${INPUT}.specstats.1 > ${INPUT}.specstats.2 


jq ' [ .[] | { "status" : .[0].status, "specifications_years": ., "specifications" : length } ] ' ${INPUT}.specstats.1 > ${INPUT}.specstats.3 

jq '[.[] |  .specifications_years[] |= . + { "year" :  .date | strptime("%Y-%m-%d") | strftime("%Y") }  ]' ${INPUT}.specstats.3 > ${INPUT}.specstats.4
jq '[.[] |  .specifications_years[] |= . + { "month" :  .date | strptime("%Y-%m-%d") | strftime("%m") }  ]' ${INPUT}.specstats.4 > ${INPUT}.specstats.5
jq '[.[] |  .specifications_years |=  group_by(.year)  ]' ${INPUT}.specstats.5 > ${INPUT}.specstats.6
jq '[.[] |  .specifications_years[] |= {"year" : .[0].year , "number" : length , "specs" : . } ]' ${INPUT}.specstats.6 > ${INPUT}.specstats.7
jq '[.[] |  .specifications_years[].specs |= group_by(.month) ]' ${INPUT}.specstats.7 > ${INPUT}.specstats.8
jq '[.[] |  .specifications_years[].specs[] |= {"month" : .[0].month , "number" : length } ]' ${INPUT}.specstats.8 > ${INPUT}.specstats.9

cp ${INPUT}.specstats.9 ${INPUT}.specstats
rm ${INPUT}.specstats.*


#jq ' [ .[] | { "status" : .[0].status, "specifications_yearmonths": [.[].date] } ] ' ${INPUT}.specstats.1 > ${INPUT}.specstats.3 
#jq '[ .[] | .specifications_yearmonths |=  [ .[] | strptime("%Y-%m-%d") | strftime("%Y-%m") ] ]' ${INPUT}.specstats.3 > ${INPUT}.specstats.4

cp ${RESULT} ${RESULT}.0

#jq '{"status" : ."publication-state" , "date" : ."publication-date", "specification": .urlref } ' ${INPUT} > ${RESULT}.in
#jq -s ".[0]+ .[1]" ${RESULT}.in ${RESULT} > ${RESULT}.0

jq ".authors = $NBAUTHORS"             ${RESULT}.0 > ${RESULT}.1
jq ".editors = $NBEDITORS"             ${RESULT}.1 > ${RESULT}.2
jq ".contributors = $NBCONTRIBUTORS"   ${RESULT}.2 > ${RESULT}.3
jq ".participants = $NBPARTICIPANTS"   ${RESULT}.3 > ${RESULT}.4
jq ".classes = $NBCLASSES"             ${RESULT}.4 > ${RESULT}.5
jq ".externalclasses = $NBEXTCLASSES"  ${RESULT}.5 > ${RESULT}.6
jq ".properties = $NBPROPERTIES"       ${RESULT}.6 > ${RESULT}.7
jq ".externalproperties = $NBEXTPROPERTIES" ${RESULT}.7 > ${RESULT}.8
jq ".totalterms = $NBTOTALTERMS "      ${RESULT}.8 > ${RESULT}.9
jq ".totalorganisations = $NBTOTALORGANISATIONS"      ${RESULT}.9 > ${RESULT}.10
jq -s ".[0].organisations = .[1] | .[0] " ${RESULT}.10  ${OUTPUT}.org.2 > ${RESULT}.11
jq -s ".[0].specifications= .[1] | .[0] " ${RESULT}.11  ${INPUT}.specstats > ${RESULT}.12

cp ${RESULT}.12 ${OUTPUT}
rm ${RESULT}.*
rm ${INPUT}.specstats
rm ${OUTPUT}.org.2


