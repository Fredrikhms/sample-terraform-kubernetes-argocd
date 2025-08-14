# Manage Kubernetes Cluster with Terraform and Argo CD


In this project I'm demonstrating you how to use [Terraform](https://www.terraform.io/) together with [Argo CD](https://argo-cd.readthedocs.io/en/stable/) to create and manage the Kubernetes cluster on [Kind](https://kind.sigs.k8s.io/).

## Prerequisites
1. Terraform CLI installed
2. Docker

## Getting Started

It is based on and forked fom the example repo from in the following article: [Manage Kubernetes Cluster with Terraform and Argo CD](https://piotrminkowski.com/2022/06/28/manage-kubernetes-cluster-with-terraform-and-argo-cd/)

First, clone that repo:
```shell
$ git clone https://github.com/Fredrikhms/sample-terraform-kubernetes-argocd.git
$ cd sample-terraform-kubernetes-argocd
```

Then initialize Terraform config: 
```shell
terraform init
```

Review the actions plan: 
```shell
terraform plan
```

Run the Terraform actions: 
```shell
terraform apply
```

## Results

After running the previous command you receive:
* 2-nodes Kind cluster running locally
* Argo CD installed on Kind
* Argo cd scanning the local git file system for updates (WIP: problems with the git permisions) 
* 'just argocd' command to run argocd dashboard.
* 'just sync' command to sync local changes with argocd. 
    - TODO: Needs to be configured using 'argocd login --core' or 'argocd login --sso'
    - TODO: If '--core' is used, then '~/.kube/config' context must be in the 'argocd' namespace. 
