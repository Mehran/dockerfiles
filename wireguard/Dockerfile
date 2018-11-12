FROM ubuntu:16.04
LABEL maintainer "Mehran <it@mehran.co>"


RUN apt-get update && apt-get install -y \
    git \
    software-properties-common \
    net-tools \
    curl \
    iproute2 \
    iptables

COPY wg.sh /wg.sh
