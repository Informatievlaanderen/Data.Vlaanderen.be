#!/bin/bash

#
# deploy the template to the generated repository when creating the final commit
# This deploy.sh will always be executed, but if no changes have happend
# then this will not lead to a git commit
#

TARGET=$1

mkdir -p ${TARGET}/.circleci
cp -r circleci/* ${TARGET}/.circleci
mkdir -p ${TARGET}/report
cp -r report/* ${TARGET}/report
