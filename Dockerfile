FROM ubuntu:14.04.3

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

#Install apt package dependencies
RUN echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y install wget curl python make g++ git
RUN apt-get clean all

#Install nodejs
RUN wget https://nodejs.org/dist/v0.12.7/node-v0.12.7-linux-x64.tar.gz
RUN tar -zxf node-v0.12.7-linux-x64.tar.gz && rm node-v0.12.7-linux-x64.tar.gz
ENV PATH $PATH:/node-v0.12.7-linux-x64/bin

#Install MeteorJS
ENV METEOR_VERSION_TAG release/METEOR@1.1.0.3
RUN git clone https://github.com/meteor/meteor.git --depth 1 --branch $METEOR_VERSION_TAG --single-branch
RUN cd meteor && git checkout -b $METEOR_VERSION_TAG
ENV PATH $PATH:/meteor

#Add the application files
RUN mkdir -p /tater/packages /tater/public /tater/.meteor
ADD ./packages /tater/packages
ADD ./public /tater/public
ADD ./.meteor /tater/.meteor
ADD ./revision.txt /revision.txt

#Prepare for production
#RUN cd /tater && meteor build /tater/build --directory
#RUN cd /tater/build/bundle/programs/server && npm install
#RUN rm -fr /tater/build/bundle/programs/server/npm/npm-bcrypt/node_modules/bcrypt && npm install bcrypt
LABEL app="tater-frontend"
EXPOSE 3000

#Start application
#ENV MONGO_URL mongodb://172.30.0.206:27017/tater-dev
#ENV METEOR_DB_NAME tater-dev
#ENV PORT 3000
#ENV ROOT_URL=http://localhost:3000
#ENV DDP_DEFAULT_CONNECTION_URL https://tater.ecohealthalliance.org:8443
#CMD node /tater/build/bundle/main.js
ENV MAIL_URL="smtp://AKIAIE2YD4YI4TQOU3QQ:AgELzBJTKCMedBlCfMafPzVBbvbEO8R5Sdm7on2+7v8y@email-smtp.us-east-1.amazonaws.com:465"
CMD cd /tater && meteor run --production
