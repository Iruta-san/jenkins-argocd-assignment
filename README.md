# Home Assignment: Jenkins + Docker + ArgoCD GitOps

**Requirements:**  
1. CI/CD Pipeline using Jenkins:  
- Set up a Jenkins pipeline that automates the build and deployment process for the chosen application.  
- Ensure the pipeline includes the necessary stages for building the application and publishing the Docker image to a container registry (specifically, Amazon Elastic Container Registry - ECR).  
- The pipeline should be triggered automatically upon changes in the application's source code repository.  
  
2. Dockerfile:  
- Create a Dockerfile for containerizing the application.  
- The Dockerfile should define the necessary steps to build a Docker image to run the application.  
  
3. GitOps Deployment using Argo CD:  
- Utilize Argo CD to implement the GitOps approach for deploying the application to a Kubernetes cluster.  
- Set up the Argo CD application using the manifests stored in a Git repository.  
- Ensure the application is continuously synchronized and deployed based on changes in the Git repository.  
  
**Bonus Tasks:**  

4. Helm Chart:  
- Enhance your solution by incorporating Helm charts for managing the Kubernetes deployment of the application.  
- Create a Helm chart that encapsulates the necessary Kubernetes manifests and provides a consistent and reproducible way to deploy the application.  
  
5. Infrastructure Provisioning with Terraform:  
- Extend the exercise by automating the provisioning of the Kubernetes cluster using Terraform.  
- Utilize Terraform to define the necessary infrastructure resources (e.g., virtual machines, networking) required for the Kubernetes cluster.  
- Ensure the provisioned infrastructure aligns with best practices and can support the deployment of the application.

  

**Deliverables:**  
1. Jenkins Pipeline:  
- Provide the Jenkins pipeline script (Jenkinsfile) that defines the complete CI/CD process, including build and deployment stages.  
  
2. Dockerfile:  
- Share the Dockerfile used to containerize the application.  
  
3. Argo CD Application:  
- Share the Argo CD application definition, including the configuration that points to the Git repository and ensures continuous deployment.  
  
4. Bonus Deliverables (if attempted):  
- Helm Chart: Share the Helm chart used for deploying the application to Kubernetes.  
- Terraform Configuration: Share the Terraform configuration files used for provisioning the Kubernetes infrastructure.  
  

Feel free to use any additional tools or technologies you believe will enhance the solution and showcase your expertise in the DevOps domain.


## Prerequisites
The repository contains all the nessecary files to demonstrate the assignment.

To succesfully do so, one should have:
 - [Docker version 20.10.19](https://docs.docker.com/desktop/install/linux-install/)
 - AWS Account with access to manage ECR repositories
 - Access to any Kubernetes cluster with ability to manage resources
 - 
 
## Installing the Jenkins
This repository contains `docker-compose.yaml` file which creates Jenkins server and one [SSH agent](https://plugins.jenkins.io/ssh-agent/), which will handle all the builds.

The plugins were installed manually.
Besides installing suggested plugins on first start, we'll need [Amazon ECR plugin](https://plugins.jenkins.io/amazon-ecr), [Docker Pipeline](https://plugins.jenkins.io/docker-workflow)

To be able to use DinD (Docker-in-Docker), the Agent container has mounted `/usr/bin/docker`,`var/run/docker.sock`paths from host.
Also by default there is no group `docker` in containers, so even with docker binaries available, the Agent has no permission to use them.

As a hotfix, there is a script `setup-agent.sh` which creates the group `docker` in the container with the same GID as on the host system and adds user `jenkins` to that group. This is surely not the best solution, but it has sufficed for this being my first experience with Jenkins. The script should be only run once after contatiners are created.

## Jenkinsfile Pipeline

The Jenkinsfile contains simple pipeline, that consists of 4 stages:

 - Checkout this repository
 - Build sample application based on NGINX
 - Test NGINX configuration in the resulting image (testing stage goes after build because to test NGINX config we still need the NGINX image)
 - Deploy the image to AWS ECR registry
 
The pipeline should be triggered on repo change. Because my Jenkins installation isn't available from the outside, I've added `pollSCM` trigger, which polls the repo every 2 minutes.

I was trying to avoid using shell script steps, but encountered a problem that docker plugin starts every container with Jenkins user ID, so for the test stage I had to use shell script.
I've commented out shell steps and left them in the Jenkinsfile for later reference.


## Sample Application. Dockerfile, Helm Chart
The application is NGINX webserver with simple page that uses [SSI commands](http://nginx.org/en/docs/http/ngx_http_ssi_module.html) to print environment information: container's hostname, IP address and current date.
Everything regarding the application is located in the `/app` directory

The Helm Chart to deploy the app is located in `/helm` directory.
The values file example is in `/helm-values`
The values are later referenced by ArgoCD manifest

## ArgoCD deployment
ArgoCD was installed to the cluster as in [tutorial](https://redhat-scholars.github.io/argocd-tutorial/argocd-tutorial/01-setup.html) with following commands:

    kubectl create namespace argocd 
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
After that the application manifest was created. It is in the file `argocd-manifest.yaml`
The manifest installed to ArgoCD controller with
`kubectl apply -f argocd-manifest.yaml`
In the manifest there are two sources with the same repositoy URL declared: one for the Helm Chart, and the other for values file, so everything can be stored in single repo, which is just enough for this assignment. 
Yet, I'd consider the better practice to create a separate Helm Repository.


## Deploy EKS with Terraform
In `/terraform` directory there are Terraform manifests to provision a small AWS EKS cluster with node group of maximum `t3.small` instances and right afterwards - install simple ArgoCD config from Helm Repo.

After apply is complete, the only thing left is to connect to cluster from console and apply ArgoCD app manifest with `kubectl`
