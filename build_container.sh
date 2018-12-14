#!/bin/bash

# If any of this commands fail, stop script.
set -e

APP_NAME=`grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VERSION=`grep 'version\:' mix.exs | cut -d '"' -f2`

# Set AWS ECS vars.
# Here you only need to set AWS_ECS_URL. I have created the others so that
# it's easy to change for a different project. AWS_ECS_URL should be the
# base url.
AWS_ECS_URL=561254188060.dkr.ecr.us-west-2.amazonaws.com
AWS_ECS_CONTAINER_NAME=eth_watcher
AWS_ECS_DOCKER_IMAGE=eth_watcher:latest
AWS_DEFAULT_REGION=us-west-2

# Build container.
# As we did before, but now we are going to build the Docker image that will
# be pushed to the repository.
docker build --pull -t $AWS_ECS_CONTAINER_NAME .

## Tag the new Docker image as latest on the ECS Repository.
docker tag $AWS_ECS_DOCKER_IMAGE "$AWS_ECS_URL"/"eth_watcher:$APP_VERSION"

# Login to ECS Repository.
eval $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)

# Upload the Docker image to the ECS Repository.
docker push "$AWS_ECS_URL"/"eth_watcher:$APP_VERSION"
