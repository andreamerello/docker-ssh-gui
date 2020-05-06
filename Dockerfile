FROM ubuntu:18.04

# preparatory steps
RUN apt-get update

# install tools
RUN apt-get install -y \
    x11-apps \
    xauth

RUN adduser --disabled-password --gecos '' test
USER test
WORKDIR /home/test
