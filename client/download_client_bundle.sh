#!/bin/bash

read -p "Docker admin user : " admin_user
read -sp "Docker admin password : " admin_password

echo "\n"
read -p "FQDN of Docker UCP host : " docker_ucp_host
read -p "TCP port configured for Docker UCP host : " docker_ucp_port

data={\"username\":\"${admin_user}\",\"password\":\"${admin_password}\"}

# Create an environment variable with the user security token
AUTHTOKEN=$(curl -sk -d ${data} https://$docker_ucp_host:$docker_ucp_port/auth/login | jq -r .auth_token)

echo "Authorisation token is $AUTHTOKEN"

# Download the client certificate bundle
curl -k -H "Authorization: Bearer $AUTHTOKEN" https://$docker_ucp_host:$docker_ucp_port/api/clientbundle -o bundle.zip

# Unzip the bundle.
unzip bundle.zip
