#!/bin/bash

ROOT_DIR=$1
PUB_CONFIG=$2
CIRCLEWORKDIR=$3 #set explicitly because CIRCLECI_WORKING_DIRECTORY is "~/project"

CONFIG_FOLDER=${PUB_CONFIG%/*}
PUB_FILE=${PUB_CONFIG##*/}

TOOLCHAINCONFIG=${CONFIG_FOLDER}/config.json

#
# merge the publication-configuration with the versions found in the branch specific one.
# For the test branch there is a special case that merges the production and test data together.
#
# use of json config files is supported by the jq tool, which is per
# default available in the circleci dockers.

# Cleanup root (just in case)
rm -rf $ROOT_DIR/*.txt
rm -rf tmp

#-------------------------------------------
#
test_json_file() {
        jq . $1 > /dev/null
        if [ "$?" -gt 0 ] ; then
                echo "ERROR: incorrect JSON FILE: $1"
                exit 1
        fi
}

# determine the last changed files
# TOOLCHAIN_TOKEN is a PAT key configured in circleci as environment variable
mkdir -p $ROOT_DIR
GENERATEDREPO=$(jq --arg bt "multilangual-dev" -r '.generatedrepository + {"filepath":"report/commit.json", "branchtag":"\($bt)"}' ${TOOLCHAINCONFIG})
./scripts/downloadFileGithub.sh "${GENERATEDREPO}" ${ROOT_DIR}/commit.json ${TOOLCHAIN_TOKEN}
sleep 5s

if jq -e . $ROOT_DIR/commit.json; then
  changesRequireBuild=false
  onlyChangedPublicationFiles=true

  COMMIT=$(jq -r .commit $ROOT_DIR/commit.json)
  PUBLICATIONPOINTSDIRS=$(jq -r '.publicationpoints | @sh'  ${CONFIG_FOLDER}/config.json)
  PUBLICATIONPOINTSDIRS=`echo ${PUBLICATIONPOINTSDIRS} | sed -e "s/'//g"`

  listOfChanges=$(git diff --name-only --no-renames $COMMIT)
  echo "write change file"
  echo $listOfChanges > changes.txt

  for i in ${PUBLICATIONPOINTSDIRS} ; do
         mkdir -p tmp/prev/config/$i
         mkdir -p tmp/next/config/$i
  done
  mkdir -p tmp/prev/config/$OTHER_FOLDER tmp/prev/config/$TEST_FOLDER tmp/prev/config/$PRODUCTION_FOLDER
  mkdir -p tmp/next/config/$OTHER_FOLDER tmp/next/config/$TEST_FOLDER tmp/next/config/$PRODUCTION_FOLDER

  GITROOT=${CONFIG_FOLDER#${CIRCLEWORKDIR}}

  while read -r filename;  do
#    if [[  $filename == "$CONFIG_FOLDER/$PUB_FILE" \
#       || ($filename == $CONFIG_FOLDER/$PRODUCTION_FOLDER/*.$PUB_FILE && ($CIRCLE_BRANCH == "$TEST_BRANCH" || $CIRCLE_BRANCH == "$PRODUCTION_BRANCH")) \
#       || ($filename == $CONFIG_FOLDER/$TEST_FOLDER/*.$PUB_FILE && $CIRCLE_BRANCH == "$TEST_BRANCH") \
#       || ($filename == $CONFIG_FOLDER/$OTHER_FOLDER/*.$PUB_FILE && ($CIRCLE_BRANCH != "$TEST_BRANCH" && $CIRCLE_BRANCH != "$PRODUCTION_BRANCH")) \
#       ]] ; then
    filenameInSelection=false
    for i in ${PUBLICATIONPOINTSDIRS} ; do
           if [[ $filename =~ ${GITROOT}/$i/.*.${PUB_FILE} ]] ; then
            filenameInSelection=true
        fi
           if [[ $filename =~ ${GITROOT}/$i/${PUB_FILE} ]] ; then
            filenameInSelection=true
        fi
    done


    if [[  $filename == "$CONFIG_FOLDER/$PUB_FILE" \
       || $filenameInSelection == "true" \
       ]] ; then
      echo "The file $filename is added for publicationchanges"
      if git show $COMMIT:$filename &>/dev/null ; then
        git show $COMMIT:$filename > tmp/prev/$filename
      fi
      if [[ -f $filename ]] ; then
        cp $filename tmp/next/$filename
      fi
      changesRequireBuild=true
    elif [[ $filename == $CONFIG_FOLDER/*/*.$PUB_FILE ]]; then
      echo "The file $filename is skipped as it is not part of the current environment"
    else
      echo "The file $filename is not a publication, everything will need to be processed"
      changesRequireBuild=true
      onlyChangedPublicationFiles=false
    fi
  done <<<"$listOfChanges"
else
  changesRequireBuild=true
  onlyChangedPublicationFiles=false
fi

if [[ $changesRequireBuild == "true" && $onlyChangedPublicationFiles == "true" ]]; then
  jq --slurp -S '[.[][]]' $(find tmp/next/config -type f) | jq '[.[] | select( .disabled | not )]' | jq '.|=sort_by(.urlref)' > tmp/next/publication.json
  jq --slurp -S '[.[][]]' $(find tmp/prev/config -type f) | jq '[.[] | select( .disabled | not )]' | jq '.|=sort_by(.urlref)' > tmp/prev/publication.json
  jq -s '.[0] - .[1]' tmp/next/publication.json tmp/prev/publication.json > tmp/addedOrChanged.json
  jq -s '.[1] - .[0]' tmp/next/publication.json tmp/prev/publication.json > tmp/removedOrChanged.json
  jq ' [.[] | .urlref ]' tmp/addedOrChanged.json > tmp/addedOrChangedUri.json
  jq ' [.[] | .urlref ]' tmp/removedOrChanged.json > tmp/removedOrChangedUri.json
  jq -s '.[0]  - .[1] ' tmp/removedOrChangedUri.json tmp/addedOrChangedUri.json > tmp/removedUri.json
  if jq -e '.[0]' tmp/removedUri.json > /dev/null 2>&1; then
    onlyChangedPublications=false
  else
    onlyChangedPublications=true
  fi
else
  onlyChangedPublications=false
fi

if [[ $changesRequireBuild == "false" ]]; then
  #no changes for this environment
  echo "true" > $ROOT_DIR/haschangedpublications.json
  cp ${PUB_CONFIG} $ROOT_DIR/publications.json.old
  echo "[]" > ${PUB_CONFIG}
  echo "[]" > $ROOT_DIR/changedpublications.json
  echo "kind of skip processing"
elif [[ $onlyChangedPublications == "true" ]]; then
  #only changes in publication
  echo "true" > $ROOT_DIR/haschangedpublications.json
  cp ${PUB_CONFIG} $ROOT_DIR/publications.json.old
  cp tmp/addedOrChanged.json ${PUB_CONFIG}
  cp tmp/addedOrChanged.json $ROOT_DIR/changedpublications.json
  echo "process only added and updated publication points"
else
  # assumes full rebuild
#  if [[ $CIRCLE_BRANCH == "$TEST_BRANCH" ]]; then
#    mkdir -p tmp/all/$PRODUCTION_FOLDER tmp/all/$TEST_FOLDER
#    cp $CONFIG_FOLDER/$PUB_FILE tmp/all/
#    cp $CONFIG_FOLDER/$PRODUCTION_FOLDER/*.$PUB_FILE tmp/all/$PRODUCTION_FOLDER
#    cp $CONFIG_FOLDER/$TEST_FOLDER/*.$PUB_FILE tmp/all/$TEST_FOLDER
#  elif [[ $CIRCLE_BRANCH == "$PRODUCTION_BRANCH" ]]; then
#    mkdir -p tmp/all/$PRODUCTION_FOLDER
#    cp $CONFIG_FOLDER/$PUB_FILE tmp/all/
#    cp $CONFIG_FOLDER/$PRODUCTION_FOLDER/*.$PUB_FILE tmp/all/$PRODUCTION_FOLDER
#  else
#    mkdir -p tmp/all/$OTHER_FOLDER
#    cp $CONFIG_FOLDER/$PUB_FILE tmp/all
#    cp $CONFIG_FOLDER/$OTHER_FOLDER/*.$PUB_FILE tmp/all/$OTHER_FOLDER
#  fi
  echo "include all selected publication points"
  for i in ${PUBLICATIONPOINTSDIRS} ; do
      mkdir -p tmp/all/$i
	  echo "try to copy all files with extension ${PUB_FILE}"
      cp ${CONFIG_FOLDER}/$i/*.${PUB_FILE}  tmp/all/$i
	  echo "try to copy file ${PUB_FILE}"
      cp ${CONFIG_FOLDER}/$i/${PUB_FILE}  tmp/all/$i
  done
  echo "errors are normal if the files of the above form are not present"
  jq --slurp -S '[.[][]]' $( find tmp/all -type f ) | jq '[.[] | select( .disabled | not )]' | jq '.|=sort_by(.urlref)' > $ROOT_DIR/allPublications.json
  if [ "$?" -gt 0 ] ; then
          echo "ERROR: one of the publication.json files contains a parse error"
          exit 1
  fi
  test_json_file ${ROOT_DIR}/allPublications.json
  echo "false" > $ROOT_DIR/haschangedpublications.json
  cp ${PUB_CONFIG} $ROOT_DIR/publications.json.old
  cp $ROOT_DIR/allPublications.json ${PUB_CONFIG}
  cp $ROOT_DIR/allPublications.json $ROOT_DIR/changedpublications.json
  echo "process all publication points"
fi
