#!/bin/bash

PUBCONFIG=scripts/publication.config
ROOTDIR=/tmp

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
# month. And then the publication would only chekcout additional
# publicationpoints for that month. That would reduce the runtime
# drastically.


create_dir_structure() {
    
}

# only iterate over those that have a repository

for row in $(jq -r '.[] | select(.repository)  | @base64 ' ${PUBCONFIG}) ; do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
   
   echo "start processing (repository): $(_jq '.urlref')"

   DIR=$(_jq '.urlref')
   mkdir -p $ROOTDIR/src/$DIR
   mkdir -p $ROOTDIR/target/$DIR
   git clone --depth=1 $(_jq '.repository') $ROOTDIR/$DIR
   pushd $ROOTDIR/$DIR
      echo "git checkout $(_jq '.branchtag')"
   popd
done

for row in $(jq -r '.[] | select(.seealso)  | @base64 ' ${PUBCONFIG}) ; do
    echo "start processing (see also): $(_jq '.urlref')"
done
