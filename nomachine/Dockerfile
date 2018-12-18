# Dockerfile to install NoMachine free v. 6 with MATE interface 
FROM debian:stretc
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y apt-utils vim xterm pulseaudio cups curl wget
RUN wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
&& dpkg -i google-chrome-stable_current_amd64.deb; exit 0
RUN apt-get install -y -f \
&& rm google-chrome-stable_current_amd64.deb

ENV NOMACHINE_PACKAGE_NAME nomachine-enterprise-desktop-evaluation_6.4.6_9_amd64.deb
ENV NOMACHINE_MD5 7a804ccf982ba67deff0994db0cdee79


RUN apt-get install -y mate-desktop-environment-core 

# Installation of ssh is required if you want to connect to NoMachine server using SSH protocol when supported.
# Comment it out if you don't need it or if you use NoMachine free.

RUN apt-get install -y ssh \
&& service ssh start 


RUN curl -fSL "http://download.nomachine.com/download/6.4/Linux/${NOMACHINE_PACKAGE_NAME}" -o nomachine.deb \
&& echo "${NOMACHINE_MD5} *nomachine.deb" | md5sum -c - \
&& dpkg -i nomachine.deb \
#&& groupadd -r nomachine -g 433 \
#&& useradd -u 431 -r -g nomachine -d /home/nomachine -s /bin/bash -c "NoMachine" nomachine \
#&& mkdir /home/nomachine \
#&& chown -R nomachine:nomachine /home/nomachine \
&& echo 'root:root' | chpasswd

RUN wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
&& dpkg -i google-chrome-stable_current_amd64.deb; exit 0
RUN apt-get install -y -f \
&& rm google-chrome-stable_current_amd64.deb

ADD nxserver.sh /

ENTRYPOINT ["/nxserver.sh"]
