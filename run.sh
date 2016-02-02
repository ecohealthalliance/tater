#!/bin/bash
#This is for use with docker, please ignore otherwise

#Install dependencies in the actual container. Do it here as opposed to during the creation of the docker image to sidestep a storage bug
cd /tater/programs/server && npm install

#MongoDB is installed in the image, but disabled by default. Remove the # sign to enable it
#service supervisor start

#Run our meteor app in production mode
export export METEOR_SETTINGS=$(cat /shared/settings-production.json)
cd /tater && node main.js
