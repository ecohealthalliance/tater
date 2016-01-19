#!/bin/bash
port=$RANDOM
quit=0

# Find an unused port (http://unix.stackexchange.com/questions/55913/whats-the-easiest-way-to-find-an-unused-local-port)
while [ "$quit" -ne 1 ]; do
  netstat -a | grep $port >> /dev/null
  if [ $? -gt 0 ]; then
    quit=1
  else
    port=`expr $port + 1`
  fi
done

# Connect to mongo, use a database named after the currently selected port
MONGO_URL=mongodb://localhost:27017/${port} meteor --port ${port} &
CUCUMBER_TAIL=1 ./node_modules/.bin/chimp --tags=${TAGS} --ddp=http://localhost:${port} --browser=chrome --path=tests/cucumber/features/ --coffee=true --chai=true --sync=false
kill `lsof -t -i:${port}`
