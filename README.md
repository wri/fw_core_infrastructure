# Forest Watcher Core Infrastructure

This repository uses terraform to define AWS resources shared by all Forest Watcher microservices.

This includes
- Application Load Balancer and LB listener
- ECS cluster for Fargate services
- S3 bucket

Additional resources shared by all GFW services are located in GFW AWS Core Infrastructure repository.
Relevant resouces include
- Document DB cluster
- Redis Custer
- Bastion host
- VPC
- SSL certificate


# Git branch naming convention and CI/CD

The branches

- production
- staging
- dev

represent infrastructure deployment in the according environment accounts on AWS. 
Github actions workflows will apply infrastructure changes to these environments automatically, 
when ever a commit is pushed to one of the branches.

Pull requests against the branches will trigger a terraform plan action, and the planned infrastructure changes will be displayed first.
It is highly recommended to always work in a feature branch and to make a pull request again the `dev` branch first.
