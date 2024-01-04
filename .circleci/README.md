# Continuous Integration / Continuous Deployment setup.

The used CI/CD environment is [CIRCLECI](https://circleci.com).

Generic documentation about the configuration language and the possibilities of CircleCI can be found [here](https://circleci.com/docs/).


# activating CircleCI 
To enable the CI/CD execution by CircleCI, one has first to login into CircleCI web application and grant CircleCI the rights to monitor the repository.
When enabled, each commit will initiate the execution of the [CircleCI configuration](./config.yml). 


# configuration CircleCI
The toolchain execution is described as a CircleCI workflow, called `generate_documentation`.
The workflow consists of a sequence of CircleCI jobs, each consisting of CircleCI steps.
A job is executed in a Docker container containing the content of this repository.
The Docker containers are based on public accessible Docker images. 
These Docker images provide specific software for the job, extending the appropriate public CircleCI image.

The executed steps within a job are either based on the specific configuration in the CircleCI language (e.g. checkout, attach_workspace, ...) or execute a script residing in this repository (i.e. the steps with `run`).
The scripts simplify the steps in in the CircleCI configuration.
Therefore these scripts can also be considered part of the CircleCI configuration.

## Parameters
The CircleCI configuration must be adapted with the real values for the publication environment.
Prior release 3.0.6 many parameters had to be explicitly set in the CircleCI configuration file, but release 3.0.6 reduced the amount to the settings of the ssh-keys.
These values should be conform with the values in `/config/config.json`.

|PARAMETER in config.yml|attribute in config.json|description|
|---|---|---|
| `$$SSHKEYFINGERPRINT`     | - | The ssh key fingerprints. See deployment instructions at [README.md](../config/README.md) |




# Tips & Tricks

The jobs share their work via the step commands `attach_workspace` and `persist_to_workspace`.
At the start of a job the outcome of the previous job is attached and after the execution of the job the result is written out.
By using the same directory `/tmp/workspace` throughout the CircleCI workflow a virtual shared disk is created.

When jobs are executed in parallel, then one has to avoid that the same directory is written by both jobs, otherwise the next job that combines the result of both jobs will initiate an error.


# Performance considerations

The performance of the CircleCI is determined by the following elements:

 - the time to checkout the GitHub repositories specified in the publication points
 - the size of the virtual shared disk 
 - the length of the longest path throughout the workflow
 - the size of the generated repository

All these elements have in common: the performance of the network. 
In the first and last case, it is limited by the download speed from GitHub.com to the CircleCI.com operational environment.
In the second and third case it is the internal network speed within the CircleCI.com operational environment.
On the unit values one has no influence, this is determined by CircleCI. 
But the scripts are made smart to reduce the impact of these elements. 



# Workflow jobs

The objective of each job is shortly described in this section.


  - *checkout* : The initiating job of the workflow. Its purpose is checking out all publication points that require processing. 
  - *extract-jsonld-details*: The job will extract a json representation from the UML file for all checked out publication points.
  - *normalise-jsonld*: Format all json representations in the same order. This done to have stable artifacts.
  - *validate-report*: This job collects all errors that are found during the json extraction process.
  - *render-translation-json*: Create/Update the translation file for each json representation for each language.
  - *render-merged-jsonld*: Merge the translation file for each language with the json representation to create a json representation per language.
  - *validate-and-generate-translation-report*: This jobs collects all errors that are found during the translation jobs
  - *render-example-templates*: render the examples per language for each publication point 
  - *render-html-details*: render the html artifact per language for each publication point 
  - *render-voc-jsonld*: render the RDF artifact for a vocabulary publication point in json-ld format
  - *render-voc-rdf*: convert the json-ld format to each RDF artifact
  - *render-shacl-details*: render the SHACL artifact per language for each publication point in json-ld format
  - *convert-json-to-ttl*: convert the json-ld format for the SHACL artifact
  - *render-context-details*: render the json-ld context per language for each publication point
  - *copy-raw*: copy the content of a publication point as-is to the target location
  - *expand-links*: copy the content of a versioned publication point that has been created during the execution of the workflow
  - *create-artifact*: assemble all generated content in a commit for the generated repository and push the change.


The jobs rely on public docker images which are either published by CircleCI or build on top of these with specific software installed.
The two main are 

  - informatievlaanderen/oslo-ea-to-rdf:json-ld-format-m1.1.1
  - informatievlaanderen/oslo-specification-generator:multilingual-dev-0.3


The first image contains the Enterprise Architect Conversion Tool, a tool that extracts from the UML model the core semantic data. 
The second image contains all artifact generation tools.

