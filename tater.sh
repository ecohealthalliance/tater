#!/bin/bash
#This is for use with docker, please ignore otherwise

#Install dependencies in the actual container. Do it here as opposed to during the creation of the docker image to sidestep a storage bug
cd /tater/programs/server && npm install

#Run our meteor app in production mode
export METEOR_SETTINGS=$(cat /shared/settings-production.json)
cd /tater && node main.js
