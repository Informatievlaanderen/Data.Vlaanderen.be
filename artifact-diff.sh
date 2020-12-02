#!/bin/bash
#set -x 
# check te difference between published artifacts on master production and oslo-generated Test

echo " arg1 = the directory containing the Data.vlaanderen.be master branch"
echo " arg2 = the directory containing the OSLO-generated test branch"

PRODUCTION=$1
TEST=$2
DETAIL=$3
DETAIL=${DETAIL:-"global"}


if [ $DETAIL == "global" ] ; then
echo "global compare "
 diff -r -q -x .git -x .gitkeep $PRODUCTION $TEST

fi

if [ $DETAIL == "rdf" ] ; then
echo "compare RDF"

PRODUCTIONFILES=`find $PRODUCTION/ns/*.ttl -printf "%f " `
for i in $PRODUCTIONFILES ; do 
   echo $i
   diff $PRODUCTION/ns/$i $TEST/ns/$i
done

fi

if [ $DETAIL == "ap" ] ; then
echo "compare applicationprofiles"

PRODUCTIONFILES=`find $PRODUCTION/doc/applicatieprofiel/ -type d -printf "%f " `
for i in $PRODUCTIONFILES ; do 
   echo $i
   diff $PRODUCTION/doc/applicatieprofiel/$i $TEST/doc/applicatieprofiel/$i
done

fi


if [ $DETAIL == "voc" ] ; then
echo "compare vocabularies"

PRODUCTIONFILES=`find $PRODUCTION/ns -type d -printf "%f " `
for i in $PRODUCTIONFILES ; do 
   echo $i
   diff $PRODUCTION/ns/$i $TEST/ns/$i
done

fi
