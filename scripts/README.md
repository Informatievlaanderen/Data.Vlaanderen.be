# The toolchain scripts

These scripts are the hart of the toolchain, together with the CIRCLECI configuration in .circleci.

The scripts are so designed that all configuration is present in the config directory, and that they do not need to be adapted when activating a publication environment.

Each script has as implicit requirement that the execution environment is the one in which is called as defined in CIRCLECI setup.
Executing the scripts thus cannot be done directly after checking out this repository. 
One has to create an execution environment (a Docker container) statisfying the needs.
This can be done by mannualy executing the CIRCLECI configuration.



