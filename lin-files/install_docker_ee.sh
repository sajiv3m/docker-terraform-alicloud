#/bin/bash
# documentation in https://docs.docker.com/install/linux/docker-ee/ubuntu/

# key parameters
#add a $DOCKER_EE_URL variable into your environment.
#Got the below one from the Docker account - trial licence
export DOCKER_EE_URL=$1

#add docker-EE version
export DOCKER_EE_VERSION=$2

#specific Docker release to install
export DOCKER_EE_RELEASE=$3

#non-root user ID that runs docker
export DOCKER_SERVER_USER=$4

# uninstall previous versions of docker
sudo apt-get remove docker docker-engine docker-ce docker.io

#Update the apt package index:
sudo apt-get update


#Install packages to allow apt to use a repository over HTTPS:
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

if [ $? -ne 0 ]; then
    echo "Previous command failed. Sleep 60s and try again"
    sleep 60
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
fi


#Add Docker’s official GPG key using your customer Docker EE repository URL:
curl -fsSL "${DOCKER_EE_URL}/ubuntu/gpg" | sudo apt-key add -

#Verify the finger print
sudo apt-key fingerprint 6D085F96

#Setup the stable repository
sudo add-apt-repository \
   "deb [arch=$(dpkg --print-architecture)] $DOCKER_EE_URL/ubuntu \
   $(lsb_release -cs) \
   stable-$DOCKER_EE_VERSION"


#update the apt-package index
sudo apt-get update


#Install a specific version/release of Docker-EE (Use "apt-cache madison docker-ee" to list the versions)
#Also install Jq - Json query
sudo apt-get install -y jq
sudo apt-get install -y docker-ee=$DOCKER_EE_RELEASE

#Add user to docker group
sudo usermod -aG docker $DOCKER_SERVER_USER

echo "Finished installing Docker EE"
