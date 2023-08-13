#!/bin/bash

# Hotfix to enable docker in docker for jenkins agent
# TODO: Find more delicate solution. 

# Get docker host group ID
GID=$(getent group docker | awk -F":" '{print $3}')

# Add docker group to agent container and put user 'jenkins' there
docker exec -it agent bash -c "groupadd -g $GID docker; gpasswd -a jenkins docker" 
