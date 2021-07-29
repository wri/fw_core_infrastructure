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