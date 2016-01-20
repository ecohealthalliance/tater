#!/bin/bash
port=$RANDOM
quit=0

# Trap interruptions to avoid leaving files or meteor instances around
function finish {
  rm testoutput.txt
  kill `lsof -t -i:${port}`
}
trap finish INT

# Find an unused port (http://unix.stackexchange.com/questions/55913/whats-the-easiest-way-to-find-an-unused-local-port)
while [ "$quit" -ne 1 ]; do
  netstat -a | grep $port >> /dev/null
  if [ $? -gt 0 ]; then
    quit=1
  else
    port=`expr $port + 1`
  fi
done

# Start meteor server if it isn't already running
if ! lsof -i:3000
then
  meteor &
fi

# Connect to mongo, use a database named after the currently selected port
tail -f testoutput.txt &
MONGO_URL=mongodb://localhost:27017/${port} meteor --port ${port} &
CUCUMBER_TAIL=1 chimp --tags=${TAGS} --ddp=http://localhost:${port} --browser=chrome --path=tests/cucumber/features/ --coffee=true --chai=true --sync=false > testoutput.txt
kill `lsof -t -i:${port}`

# Determine exit code based on test output
if grep -q "failed steps" testoutput.txt
then
  rm testoutput.txt
  echo "Tests Failed"
  exit 1
fi
rm testoutput.txt
echo "Tests Passed"
exit
