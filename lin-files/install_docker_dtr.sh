#/bin/sh
# documentation in https://docs.docker.com/reference/dtr/2.6/cli/install/

# key parameters


export DOCKER_UCP_HOST=$1

export DOCKER_ADMIN_USER=$2
export DOCKER_ADMIN_PASSWORD=$3
export DOCKER_UCP_PORT=$4
export UCP_NODE=$(cat /etc/hostname)


echo "Installing Docker Trusted Registry (DTR)"

    # Install Docker Trusted Registry
    # Uses port 443 for secure access
    docker run \
        --rm \
        docker/dtr:latest install \
        --dtr-external-url "https://${DOCKER_UCP_HOST}" \
        --ucp-username $DOCKER_ADMIN_USER \
        --ucp-password $DOCKER_ADMIN_PASSWORD \
        --ucp-node $UCP_NODE \
        --ucp-url "https://${DOCKER_UCP_HOST}:${DOCKER_UCP_PORT}" \
        --ucp-insecure-tls 

    echo "Finished installing Docker Trusted Registry (DTR)"