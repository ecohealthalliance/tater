#!/bin/bash

port=$RANDOM
SECONDS=0
quit=0

export ALLOW_TOKEN_ACCESS=true

touch testoutput${port}.txt
# Trap interruptions to avoid leaving files or meteor instances around
function finish {
  rm testoutput${port}.txt
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

# Check if Tika server is running on localhost
document_text='Test Document String Ponies 123'
tika_result=$(echo $document_text | curl -s -X PUT --data-binary @- http://localhost:9998/tika --header "Content-type: application/octet-stream" --header "Accept: text/plain")
tika_result=$(echo $tika_result | xargs) # trim
if [ "$tika_result" != "$document_text" ]
then
  # echo 'Unable to reach Tika on port 9998'
  if [ ! -e "tika-server.jar" ]
  then
    # echo 'No Tika server binary found, downloading...'
    curl -L h http://mirror.cc.columbia.edu/pub/software/apache/tika/tika-server-1.11.jar > tika-server.jar
  fi
  java -jar tika-server.jar &
fi

# Start meteor server if it isn't already running
if ! lsof -i:3000
then
  meteor &
fi

# Connect to mongo, use a database named after the currently selected port
tail -f testoutput${port}.txt &
MONGO_URL=mongodb://localhost:3001/${port} meteor --settings settings-development.json --port ${port} &
CUCUMBER_TAIL=1 chimp --tags=${TAGS} --ddp=http://localhost:${port} --browser=chrome --path=tests/cucumber/features/ --coffee=true --chai=true --sync=false > testoutput${port}.txt
kill `lsof -t -i:${port}`

echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed"

# Determine exit code based on test output
if grep -q "failed steps" testoutput${port}.txt
then
  rm testoutput${port}.txt
  echo "Tests Failed"
  exit 1
fi
rm testoutput${port}.txt
echo "Tests Passed"
exit
