#!/bin/bash


# key parameters
export DOCKER_UCP_HOST=$1
export DOCKER_ADMIN_USER=$2
export DOCKER_ADMIN_PASSWORD=$3

export DOCKER_UCP_PORT=$4
export NODE_NAME=$(hostname)



#Install worker node i.e. join Swarm

# Wait until UCP is intalled on the manager node
## Checking UCP status
export STATUS=$(curl --request GET --url "https://${DOCKER_UCP_HOST}:${DOCKER_UCP_PORT}" --insecure --silent --output /dev/null -w '%{http_code}' --max-time 5) 
echo "checkUCP: API status for ${DOCKER_UCP_HOST} returned as: ${STATUS}"

echo "Sleeping 2 minutes.. UCP may have just come up.."
sleep 120

while [ "$STATUS" -ne 200 ]
do
    echo "UCP not ready yet... sleeping 2 minutes on ${NODE_NAME}"
    sleep 120
    STATUS=$(curl --request GET --url "https://${DOCKER_UCP_HOST}:${DOCKER_UCP_PORT}" --insecure --silent --output /dev/null -w '%{http_code}' --max-time 5) 
    echo "checkUCP: API status for ${DOCKER_UCP_HOST} returned as: ${STATUS}"
done

echo "UCP is ready.. will join this worker node to Swarm - ${NODE_NAME}"

# Get Authentication Token
AUTH_TOKEN=$(curl --request POST --url "https://${DOCKER_UCP_HOST}:${DOCKER_UCP_PORT}/auth/login" --insecure --silent --header 'Accept: application/json' --data '{ "username": "'${DOCKER_ADMIN_USER}'", "password": "'${DOCKER_ADMIN_PASSWORD}'" }' | jq --raw-output .auth_token)

# Get Swarm Manager IP Address + Port
UCP_MANAGER_ADDRESS=$(curl --request GET --url "https://${DOCKER_UCP_HOST}:${DOCKER_UCP_PORT}/info" --insecure --silent --header 'Accept: application/json' --header "Authorization: Bearer ${AUTH_TOKEN}" | jq --raw-output .Swarm.RemoteManagers[0].Addr)
   
# Get Swarm Join Tokens
UCP_JOIN_TOKENS=$(curl --request GET --url "https://${DOCKER_UCP_HOST}:${DOCKER_UCP_PORT}/swarm" --insecure --silent --header 'Accept: application/json' --header "Authorization: Bearer ${AUTH_TOKEN}" | jq .JoinTokens)
UCP_JOIN_TOKEN_WORKER=$(echo "${UCP_JOIN_TOKENS}" | jq --raw-output .Worker)

## UCP Manager token not required for now
## UCP_JOIN_TOKEN_MANAGER=$(echo "${UCP_JOIN_TOKENS}" | jq --raw-output .Manager)

echo "joinUCP: Joining Swarm as a Worker"
docker swarm join --token "${UCP_JOIN_TOKEN_WORKER}" "${UCP_MANAGER_ADDRESS}"


echo "joinUCP: Finished joining worker node to UCP.. may take a while to be in Ready state"
