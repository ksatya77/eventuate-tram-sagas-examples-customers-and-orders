#! /bin/bash

set -e


. ./set-env-${DATABASE?}.sh

docker-compose -f docker-compose-${DATABASE?}.yml down -v

docker-compose -f docker-compose-${DATABASE?}.yml up -d --build zookeeper ${DATABASE?} kafka cdcservice

./wait-for-${DATABASE?}.sh

./gradlew -x :end-to-end-tests:test build

docker-compose -f docker-compose-${DATABASE?}.yml up -d --build 

./wait-for-services.sh $DOCKER_HOST_IP "8081 8082"

./gradlew :end-to-end-tests:cleanTest :end-to-end-tests:test

docker-compose -f docker-compose-${DATABASE?}.yml down -v
