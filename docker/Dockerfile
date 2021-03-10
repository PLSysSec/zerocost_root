FROM ubuntu:latest

# set a directory for the app
WORKDIR /usr/src/

############### Only docker specific setup goes here ###############

# ssh key for access to repos
COPY id_rsa.pub /root/.ssh/id_rsa.pub
COPY id_rsa /root/.ssh/id_rsa

RUN dpkg --add-architecture i386
RUN apt update
RUN apt -y dist-upgrade

RUN apt install -y apt-utils

# Setup timezone
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles
RUN apt install -y tzdata

# Setup sudo
RUN apt -y install sudo
# Disable annoying warning when using sudo
COPY sudo.conf /etc/sudo.conf
# Set private key permissions
RUN chmod 400 /root/.ssh/id_rsa

# install editor for convenience
RUN apt install -y nano

# Setup shell env
ENV SHELL=/bin/bash

############### Get the top level repo and run setup ###############
RUN apt -y install git make
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN git clone git@github.com:PLSysSec/zerocost_root.git
RUN cd ./zerocost_root && make get_source
RUN cd ./zerocost_root && git pull
RUN cd ./zerocost_root && make bootstrap

# Run bash automatically on startup
CMD ["bash"]
