#!/bin/bash

echo "this script is deprecated, please use findPublicationsToUpdate.sh followed by checkoutRepositories.sh"


PUBCONFIG=$2
ROOTDIR=$1

# some test calls
#jq -r '.[] | @sh "echo \(.urlref)"' publication.config | bash -e
#jq -r '.[] | @sh "./checkout-one.sh \(.)"' publication.config | bash -e

#
# create the directory layout which allows the ea-to-rdf & the
# specgenerator to do there work:
# * src/DIR: the git repository which contains the source
# * target/DIR: the generated artificats that will be committed for publication
# * report/DIR: a directory with all intermediate and log reports to
#               understand the execution trace.  Will also be
#               committed to github, but on a separate directory so
#               that it will not be served by the proxy * the
#               implementation of the see-also rules

# use of json config files is supported by the jq tool, which is per
# default available in the circleci dockers.

# the data that is used to create the directory setup should be
# integrated with the data in the cloned repository the reason for
# this is that some data such as the navigation trail is part of the
# publication section and not of the local repository

# performance consideration: the checkout & build times might increase
# rapidely as there are many publication points to handle we coudl
# consider to create a docker with the to-be-generated situation in a
# previous state and start form that one.  The build of a new docker
# should than be done on regular time (not on every commit) e.g. 1 /
# month. And then the publication would only chekcout additonal
# publicationpoints for that month. That would reduce the runtime
# drastically.


cleanup_directory() {
    local MAPPINGFILE=`jq -r 'if (.filename | length) > 0 then .filename else @sh "config/eap-mapping.json"  end' .publication-point.json`
    if [[ -f ".names.txt" && -f $MAPPINGFILE ]]
    then
	STR=".[] | select(.name == \"$(cat .names.txt)\") | [.]"
	jq "${STR}" ${MAPPINGFILE} > .map.json
	jq -r '.[] | @sh "find . -name \"*.eap\" !  -name \(.eap) -type f -exec rm -f {} + "' .map.json | bash -e
        rm -rf .git
    fi
}

# Cleanup root (just in case)
rm -rf $ROOTDIR/*.txt

if [ ! -f "${PUBCONFIG}" ] ; then
    echo  "file doesn't exist - ${PUBCONFIG}"
    exit -1
fi

# determin the last changed files
mkdir -p $ROOTDIR
curl -o $ROOTDIR/commit.json https://raw.githubusercontent.com/Informatievlaanderen/OSLO-Generated/$CIRCLE_BRANCH/report/commit.json
sleep 5s
jq . $ROOTDIR/commit.json
if  [ $? -eq 0 ] ; then
   COMMIT=`jq -r .commit $ROOTDIR/commit.json`
   listofchanges=$(git diff --name-only $COMMIT)
   echo $listofchanges > changes.txt
   if [ "$listofchanges" == "config/publication.json" ] ; then
       git show $COMMIT:config/publication.json > prev
       jq -s '.[0] - .[1]' config/publication.json prev > $ROOTDIR/changedpublications.json
       cat $ROOTDIR/changedpublications.json
       echo "true" > $ROOTDIR/haschangedpublications.json
       cp ${PUBCONFIG} $ROOTDIR/publications.json.old
#       echo "false" > $ROOTDIR/haschangedpublications.json
       cp $ROOTDIR/changedpublications.json ${PUBCONFIG}

   else
       cp ${PUBCONFIG} $ROOTDIR/changedpublications.json
       echo "false" > $ROOTDIR/haschangedpublications.json
       echo "process all publication points";
   fi

else
   # no previous commit
   # assumes full rebuild
   cp ${PUBCONFIG} $ROOTDIR/changedpublications.json
   echo "false" > $ROOTDIR/haschangedpublications.json
   echo "process all publication points";
fi


toolchainhash=$(git log | grep commit | head -1 | cut -d " " -f 2)

# Process the publications.config file
if cat ${PUBCONFIG} | jq -e . > /dev/null 2>&1
then
    # only iterate over those that have a repository
    for row in $(jq -r '.[] | select(.repository)  | @base64 ' ${PUBCONFIG}) ; do
	_jq() {
	    echo ${row} | base64 --decode | jq -r ${1}
	}

	DISABLED=$(_jq '.disabled')

	if [ "$DISABLED" == "" ] || [ "$DISABLED" == "null" ] || [ "$DISABLED" == "false" ] ; then
        # start non  disabled

	FORM=$(_jq '.type')
	if [ "$FORM" == "raw" ]
	then
	    MAIN=raw-input
	else
	    MAIN=src
	fi

	echo "start processing (repository): $(_jq '.repository') $(_jq '.urlref') $MAIN"

	DIR=$(_jq '.urlref')
	NAME=$(_jq '.name')
	RDIR=${DIR#'/'}
	mkdir -p $ROOTDIR/$MAIN/$RDIR
	mkdir -p $ROOTDIR/target/$RDIR
	mkdir -p $ROOTDIR/report/$RDIR
	git clone $(_jq '.repository') $ROOTDIR/$MAIN/$RDIR

	pushd $ROOTDIR/$MAIN/$RDIR
           if ! git checkout $(_jq '.branchtag')
 	   then
	       # branch could not be checked out for some reason
	       echo "failed: $ROOTDIR/$MAIN/$RDIR $(_jq '.branchtag')" >> $ROOTDIR/failed.txt
	   fi

	   # Save the Name points to be processed
	   if [ ! -z "$NAME" -a "$NAME" != "null" ]
	   then
	       echo "check name $NAME is present"
               echo "$NAME" >> .names.txt
	   fi
	   comhash=$(git log | grep commit | head -1 | cut -d " " -f 2)
	   echo "hashcode to add: ${comhash}"
	   echo ${row} | base64 --decode | jq --arg comhash "${comhash}" --arg toolchainhash "${toolchainhash}" '. + {documentcommit : $comhash, toolchaincommit: $toolchainhash, hostname: "https://otl-test.data.vlaanderen.be" }' > .publication-point.json
	   cleanup_directory
        popd

	if [ "$MAIN" == "src" ]
	then
	    echo "$RDIR" >> $ROOTDIR/checkouts.txt
	fi

        if [ "$MAIN" == "raw-input" ]
        then
            echo "force removal of .git directory - $ROOTDIR/$MAIN/$RDIR"
            echo "$RDIR" >> $ROOTDIR/rawcheckouts.txt
            cat $ROOTDIR/rawcheckouts.txt
            rm -rf $ROOTDIR/$MAIN/$RDIR/.git
            localdirectory=$(_jq '.directory')
            if [ "$localdirectory" != "null" ] ;  then
             echo "only take the content of the directory $localdirectory"
             rm -rf /tmp/rawdir
             mkdir -p /tmp/rawdir
             cp -r $ROOTDIR/$MAIN/$RDIR/$localdirectory/* /tmp/rawdir
             rm -rf $ROOTDIR/$MAIN/$RDIR/*
             cp -r /tmp/rawdir/* $ROOTDIR/$MAIN/$RDIR/
            else
             echo "no localdirectory defined, keep content as is"
            fi
        fi
        fi

    done


    jq '[.[] | if has("seealso") then . else empty  end ] ' ${PUBCONFIG} > $ROOTDIR/links.txt

    if [ -f "$ROOTDIR/failed.txt" ]
    then
       echo "failed checking out branches"
       cat $ROOTDIR/failed.txt
       exit -1
    fi
    touch $ROOTDIR/checkouts.txt
    touch $ROOTDIR/rawcheckouts.txt
else
    echo "problem in processing: ${PUBCONFIG}"
	exit -1
fi
