#!/bin/bash
#This is for use with docker, please ignore otherwise

cd /tater/programs/server && npm install
cd /tater && node main.js
