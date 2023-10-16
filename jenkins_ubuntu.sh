#!/bin/bash

set -e

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install fontconfig openjdk-11-jre -y
sudo apt-get install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Check if Jenkins service is active
if systemctl is-active --quiet jenkins; then
  echo "==========='Jenkins is running.'============="
else
  echo "==========='Jenkins is not running.'============="
fi

sleep 10

# Install Terraform 
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update -y
sudo apt-get install terraform -y
terraform --version

# Install trivy
# Ref : https://aquasecurity.github.io/trivy/v0.18.3/installation/
wget https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.deb
sudo dpkg -i trivy_0.18.3_Linux-64bit.deb


sleep 10

# Install Docker

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y 
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl enable docker
sudo systemctl start docker

# Run sonarqube docker container

if ! systemctl is-active --quiet docker; then
  # Docker is not running, so start it
  sudo systemctl start docker
fi

# Check if Docker is running now
if systemctl is-active --quiet docker; then
  # Docker is running, so run the Docker container
  if ! sudo docker ps -q --filter name=sonar | grep -q . ; then
    # The "sonar" container is not running, so start it
    sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
    echo "SonarQube container started."
  else
    echo "SonarQube container is already running."
  fi
else
  echo "Docker is not running and couldn't be started."
fi
echo "Jenkins Initial Password : $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
