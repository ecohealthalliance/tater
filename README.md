# tater
Manual annotation interface

## Testing
To run model unit tests:
`spacejam test-packages packages/models/`

To run end-to-end tests:
`VELOCITY_CI=1 CHIMP_OPTIONS="--browser=chrome --no-screenshotsOnError" meteor --test`

To run a single test:
Put the tag `@dev` immediately above the test, then start your meteor server by running
`CHIMP_OPTIONS="--tags=@dev --browser=chrome --no-screenshotsOnError" meteor`

## Copying production database to local machine
First get the file `infrastructure.pem` from another EHA developer and place it in `~/.ssh`
Then run `./scripts/restore_database`

## Setting up a default user for an empty database
In the browser console, run `Meteor.call('createDefaultUser', YOUR_USERNAME, YOUR_PASSWORD)`
