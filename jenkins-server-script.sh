#!/bin/bash

set -x

# install jenkins

sudo yum update
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# install git

sudo yum install git -y

# install terraform

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# install docker

sudo amazon-linux-extras install docker -y
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker


# Install trivy
# Ref: https://aquasecurity.github.io/trivy/v0.46/getting-started/installation/
# What is Trivy : https://www.aquasec.com/products/trivy/

sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.46.0/trivy_0.46.0_Linux-64bit.rpm


# install kubectl

sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mkdir -p $HOME/bin && sudo cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin

# Run sonarqube docker container

# Check if Docker is installed
if ! command -v docker > /dev/null; then
  echo "Docker is not installed. Please install Docker and try again."
  exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null; then
  echo "Docker is not running. Please start Docker and try again."
  exit 1
fi

sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
