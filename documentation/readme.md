# Documentation of the data

## deployment process

Data.vlaanderen.be has been setup to minimize the rollout and maintenance effort of any change to the system in a predicatable way. 
The figure below shows the four layers of the envoriment. 
![The process][update_process.jpg]

The bottom layer is the cloud infrastructure. For Data.vlaanderen.be this is [Azure][https://azure.microsoft.com/]. 

On top of that, the infrastructure is deployed. The infrastructure is setup using [Terraform][https://www.terraform.io/]. 
The terraform configuration describes a [docker swarm][https://github.com/docker/swarm] setup.
Docker swarm is native clustering for Docker. Docker swarm is responsible for executing the services of data.vlaanderen.be.
It monitors the health of the services and in case problems are detected it will 


