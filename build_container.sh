#!/bin/bash

set -e

APP_NAME=`grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VERSION=`grep 'version\:' mix.exs | cut -d '"' -f2`

AWS_ECS_URL=561254188060.dkr.ecr.us-west-2.amazonaws.com
AWS_ECS_CONTAINER_NAME=eth_watcher
AWS_ECS_DOCKER_IMAGE=eth_watcher:latest
AWS_DEFAULT_REGION=us-west-2

docker build --pull -t $AWS_ECS_CONTAINER_NAME .

docker tag $AWS_ECS_DOCKER_IMAGE "$AWS_ECS_URL"/"eth_watcher:$APP_VERSION"

eval $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)

docker push "$AWS_ECS_URL"/"eth_watcher:$APP_VERSION"
