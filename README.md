# tater
Manual annotation interface

## Testing
First install the Java Runtime Environment:
http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html

Also install spacejam (for running unit tests via command line interface): `npm install -g spacejam@1.2.1`

To run model unit tests:
`spacejam test-packages packages/models/`

To run end-to-end tests:
`make test`

To run a single test:
Put the tag `@dev` immediately above the test, then start your meteor server by running
`make devtest`

## Copying production database to local machine
First get the file `infrastructure.pem` from another EHA developer and place it in `~/.ssh`

Start your meteor server, then run `make data`

## Setting up a default user for an empty database
In the browser console, run `Meteor.call('createDefaultUser', <your@email>)`
Then follow the link in the email that you should receive to set the password

## Adding initial coding keywords for an empty database
In the browser console, run `Meteor.call("createDefaultCodes")`
or `Meteor.call("createDefaultCodes", "uno", "dos", "tres")`

## Building the docker image, and running the container
Build the app with the shell script  
`./build.sh`

Build the docker image  
`sudo docker build -t tater .`

Run the newly built image  
`sudo docker run --restart=always -e MONGO_URL=mongodb://<ip address>:<port>/<database name> -e ROOT_URL=http://<ip or FQDN> -e PORT=80 -p 80:80 --name tater tater`

## License
Copyright 2016 EcoHealth Alliance

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
