# Documentation of the data

## deployment process

Data.vlaanderen.be has been setup to minimize the rollout and maintenance effort of any change to the system in a predicatable way. 
The figure below shows the four layers of the envoriment. 

![The process](update-process.jpg)

The bottom layer is the cloud infrastructure. For Data.vlaanderen.be this is [Azure](https://azure.microsoft.com/). 

On top of that, the infrastructure is deployed. The infrastructure is setup using [Terraform](https://www.terraform.io/). 
The terraform configuration describes a [docker swarm](https://github.com/docker/swarm) setup.
Docker swarm is native clustering for Docker. Docker swarm is responsible for executing the services of data.vlaanderen.be.
It monitors the health of the services. In case problems are detected docker swarm will try to respawn the malfunctioning service 
in order to restore the application.

The application itself is controlled by a docker-compose description. The docker-compose description is an infrastructure neutral 
description of the application. It details how the services are connected with eachother. When developing on the services, the code 
is pushed in the source control system (github.com and a local gitlab instance ). The automation triggers a build (of a new docker instance of the services) 
and testing of the build.  When the code change passes all checks, it can be committed to the master branch and tagged. The tagged
docker service can now be activated in the docker-compose description. Any change to the docker-compose description is automatically 
deployed on the infrastructure.  The use of branches and tags allows to precisely document which service is running on which environment.

The final layer is the data content layer. For having a life system with the correct content the data has to be uploaded. Some data is comming from external systems 
and will be retrieved by querying them.  But other data such as the static html pages will be retrieved from source control. The service will regulary 
poll for changes; when a change is detected the existing data of the service is replaced. Content editors hence follow the same approach as
the software development.

## the application architecture

The resulting application is depicted in the figure below. 

![Current Architecture](huidige-architectuur.jpg)

At the infracture layer, descriped by a terraform description,  we have setup a loadbalancer. It is the entrypoint for all 
traffic between the external world (the Internet) and the internal services.
To run the services a cluster of 3 nodes has been created. This gives a minimal amount of robustness, currently sufficient for our needs. 
But it can be easily increased when required by interacting with terraform. Additionally we have added a shared disk on which the current 
state will be stored. Finally we also added a blobstore for storing large datasets.

The application layer shows the key components of the application.
A proxy which handles the content-negoration. The proxy is the only service that is accesssible from the public network.
It also offers access to webservices to render the static html pages. Next it contains the html 
and RDF renderers for the subjectpages, which data comes from a SPARQL endpoint. The SPARQL endpoint is accessed through a query cache. 
And then the key data provider: the RDF store, which also serves the SPARQL endpoint. 

The RDFstore data is fed by the data synchronisation service.

To monitor the health of the running services, all logs are shipped to an external system. This enables to follow the activity on the system
while not loading that on the system itself.




## the html subjectpage renderer 
The html subjectpage renderer itself is a complicated setup, consisting of serveral services.

![html renderer](html-subjectpagina-rendering.jpg)

Its implementation is based on the mu.semte.ch ecosystem. Using the mu.resources service, for a given resource, the RDF data is retrieved from the 
SPARQL endpoint and turned into a JSON-API compliant representation. The JSON-API resource api is used in an Ember.js app to create the subject pages.
For each resource type (e.g. Address, Building, Organisation) a mu.resources configuration has to be made.



