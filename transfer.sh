#!/bin/bash

set -x

CASE=${1:=false}
GENERATED=$2
TARGET=$3

echo "copy document paths"
TARGETS="/doc/applicatieprofiel/perceel /doc/applicatieprofiel/bedrijventerrein /doc/vocabularium/perceel /doc/vocabularium/bedrijventerrein"

#TARGETS="/doc/applicatieprofiel/cultureel-erfgoed-object"


for i in $TARGETS ; do
	echo copy $i
	cp -r $GENERATED/$i site-skeleton/$i
	cp $GENERATED/$i/shacl/*.ttl site-skeleton/shacl
	cp $GENERATED/$i/context/*.jsonld site-skeleton/context
done

echo "copy ns paths"
echo "CHECK IF THE FILENAME FITS THE URL" 
TARGETS="/ns/perceel /ns/bedrijventerrein"

for i in $TARGETS ; do
	echo copy $i
	cp -r $GENERATED/$i site-skeleton/$i
	cp $GENERATED/$i/voc/* site-skeleton/ns/
done

if [ $CASE = "true" ] ; then
pushd site-skeleton/doc
 find . -exec sed -i "s/test.data.vlaanderen.be/data.vlaanderen.be/g" {} \;
popd
pushd site-skeleton/ns
 find . -exec sed -i "s/test.data.vlaanderen.be/data.vlaanderen.be/g" {} \;
popd
fi

