# tater
Manual annotation interface

## Testing
First install the Java Runtime Environment:
http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html

Also install spacejam (for running unit tests via command line interface): `npm install -g spacejam`

To run model unit tests:
`spacejam test-packages packages/models/`

To run end-to-end tests:
`VELOCITY_CI=1 CHIMP_OPTIONS="--browser=chrome --chai --sync=false meteor --test`

To run a single test:
Put the tag `@dev` immediately above the test, then start your meteor server by running
`CHIMP_OPTIONS="--watch --watchTags=@dev --browser=chrome --chai --sync=false" meteor`

## Copying production database to local machine
First get the file `infrastructure.pem` from another EHA developer and place it in `~/.ssh`
Then run `./scripts/restore_database`

## Setting up a default user for an empty database
In the browser console, run `Meteor.call('createDefaultUser', YOUR_USERNAME, YOUR_PASSWORD)`

## Building the docker image, and running the container
Build the app with the shell script  
`./build.sh`

Build the docker image  
`docker build -t tater .`

Run the newly built image  
`docker run --restart=always -e MONGO_URL=mongodb://<ip address>:<port>/<database name> -e ROOT_URL=http://<ip or FQDN> -e PORT=80 -p 80:80 --name tater tater`
