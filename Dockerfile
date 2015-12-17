FROM ubuntu:14.04.3

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

#Install apt package dependencies
RUN echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe" >> /etc/apt/sources.list
RUN apt-get clean all && apt-get update
RUN apt-get -y install wget curl python make g++ git mongodb supervisor
RUN apt-get clean all

#Install nodejs
RUN wget https://nodejs.org/download/release/v0.10.40/node-v0.10.40-linux-x64.tar.gz
RUN tar -zxf node-v0.10.40-linux-x64.tar.gz && rm node-v0.10.40-linux-x64.tar.gz
ENV PATH $PATH:/node-v0.10.40-linux-x64/bin

#Install MeteorJS
ENV METEOR_VERSION_TAG release/METEOR@1.2.1
RUN git clone https://github.com/meteor/meteor.git --depth 1 --branch $METEOR_VERSION_TAG --single-branch
RUN cd meteor && git checkout -b $METEOR_VERSION_TAG
ENV PATH $PATH:/meteor

#Add the application files
ADD run.sh /run.sh
ADD ./build/bundle /tater
ADD ./revision.txt /revision.txt
ADD supervisor-mongod.conf /etc/supervisor/conf.d/mongod.conf

#Prepare for production
LABEL app="tater-frontend"
EXPOSE 3000
ENV MAIL_URL="smtp://AKIAIE2YD4YI4TQOU3QQ:AgELzBJTKCMedBlCfMafPzVBbvbEO8R5Sdm7on2+7v8y@email-smtp.us-east-1.amazonaws.com:465"

#Start application
CMD bash run.sh
