# tater
Manual annotation interface

## Testing
To run model unit tests:
`spacejam test-packages packages/models/`

To run end-to-end tests:
`VELOCITY_CI=1 CHIMP_OPTIONS="--browser=chrome --no-screenshotsOnError" meteor --test`

## Copying production database to local machine
First get the file `infrastructure.pem` from another EHA developer and place it in `~/.ssh`
Then run `./scripts/restore_database`
