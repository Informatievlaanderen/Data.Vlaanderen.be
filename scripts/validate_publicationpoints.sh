#!/bin/bash

# Arg1 = The configuration directory
# Arg2 = The location where the generated repository is checked out
# Arg3 = The CircleCI working directory

CONFIGDIR=$1
GENERATEDREPODIR=$2

CIRCLEWORKDIR=$3 #set explicitly because CIRCLECI_WORKING_DIRECTORY is "~/project"

PUBLICATIONPOINTSDIRS=$(jq -r '.publicationpoints | @sh' ${CONFIGDIR}/config.json)
PUBLICATIONPOINTSDIRS=$(echo ${PUBLICATIONPOINTSDIRS} | sed -e "s/'//g")



for dir in ${PUBLICATIONPOINTSDIRS}; do
    echo $dir
    PUBLICATIONPOINTSFILES=$(find  $dir -name *.publication.json )
    for f in ${PUBLICATIONPOINTSFILES} ; do
	    echo $f
            check.sh $file ${GENERATEDREPODIR}
    done
done

