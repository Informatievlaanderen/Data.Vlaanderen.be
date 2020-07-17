#!/bin/bash

set -x

GENERATED=$1
TARGET=$2

echo "copy document paths"
TARGETS="/doc/applicatieprofiel/cultureel-erfgoed-object /doc/applicatieprofiel/cultureel-erfgoed-event /doc/vocabularium/cultureel-erfgoed/kandidaatstandaard/2020-07-17 /doc/applicatieprofiel/cultureel-erfgoed-object/kandidaatstandaard/2020-07-17 /doc/applicatieprofiel/cultureel-erfgoed-event/kandidaatstandaard/2020-07-17 /doc/vocabularium/cultureel-erfgoed/ontwerpstandaard/2020-07-02 /doc/applicatieprofiel/cultureel-erfgoed-object/ontwerpstandaard/2020-07-02 /doc/applicatieprofiel/cultureel-erfgoed-event/ontwerpstandaard/2020-07-02 /doc/applicatieprofiel/cultureel-erfgoed-object/ontwerpstandaard/2020-05-28 /doc/applicatieprofiel/cultureel-erfgoed-event/ontwerpstandaard/2020-05-28 /doc/applicatieprofiel/cultureel-erfgoed-object/ontwerpstandaard/2020-05-05"
#TARGETS="/doc/applicatieprofiel/cultureel-erfgoed-object"


for i in $TARGETS ; do
	echo copy $i
	cp -r $GENERATED/$i site-skeleton/$i
	cp $GENERATED/$i/shacl/*.ttl site-skeleton/shacl
	cp $GENERATED/$i/context/*.jsonld site-skeleton/context
done

echo "copy ns paths"
TARGETS="/ns/cultureel-erfgoed"

for i in $TARGETS ; do
	echo copy $i
	cp -r $GENERATED/$i site-skeleton/$i
	cp $GENERATED/$i/voc/* site-skeleton/ns/
done

# pushd site-skeleton/doc
# find . -exec sed -i "s/test.data.vlaanderen.be/data.vlaanderen.be/g" {} \;
# popd


