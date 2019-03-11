#/bin/bash
# documentation in https://docs.docker.com/reference/ucp/3.1/cli/install/

# key parameters

#specific Docker UCP version to install, also the hostname and USER_ID
export DOCKER_UCP_VERSION=$1
export DOCKER_UCP_HOST=$2

export DOCKER_ADMIN_USER=$3
export DOCKER_ADMIN_PASSWORD=$4

export DOCKER_IP_ADDR=$5
export DOCKER_UCP_PORT=$6
export POD_CIDR=$7


# Pull the Docker UCP image - a specific version
docker image pull docker/ucp:$DOCKER_UCP_VERSION

# Install UCP
docker container run --rm -it --name ucp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    docker/ucp:$DOCKER_UCP_VERSION install \
    --san $DOCKER_UCP_HOST \
    --license "$(cat /tmp/lin-files/docker_subscription.lic)" \
    --admin-username $DOCKER_ADMIN_USER \
    --admin-password $DOCKER_ADMIN_PASSWORD \
    --controller-port $DOCKER_UCP_PORT \
    --host-address $DOCKER_IP_ADDR \
    --pod-cidr $POD_CIDR

echo "Finished installing Docker Universal Control Plane...will sleep for 2 mins.."


