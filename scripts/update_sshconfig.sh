#!/bin/bash

# This script will enrich the CIRCLECI ssh config so that a git clone operation can be executed.
# When CIRCLECI project is configured with an additional ssh key then it will create the following sshconfig:
#
# Host <CIRCLECIHOSTNAME>
#  IdentitiesOnly yes
#  IdentityFile /home/circleci/.ssh/id_rsa_<FINGERPRINTPRIVATEKEY>
#
# This script will update this config to 
#
# Host <CIRCLECIHOSTNAME>
#  HostName github.com
#  User git
#  IdentitiesOnly yes
#  IdentityFile /home/circleci/.ssh/id_rsa_<FINGERPRINTPRIVATEKEY>
#
# After this change the git command to clone a repository
#   git clone git@github.com:<ORG>/<REPO>.git
#   
# can be replaced with
#   git clone git@<CIRCLECIHOSTNAME>:<ORG>/<REPO>.git
#
# This allows to support checkout of private repositories using a specific ssh key for this repository



# arg1 the <CIRCLECIHOSTNAME> that should be updated


sed  -i -e "/Host ${CIRCLECIHOSTNAME}/a \ \ User git" ~/.ssh/config
sed  -i -e "/Host ${CIRCLECIHOSTNAME}/a \ \ HostName github.com" ~/.ssh/config
