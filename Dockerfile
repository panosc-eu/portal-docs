# syntax=docker/dockerfile:1
FROM ubuntu

RUN apt-get update
# tzdata:
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
# other bare minimum packages: curl and sudo
RUN apt-get install -y curl sudo
RUN useradd -ms /bin/bash -G sudo portal && \
    usermod -aG sudo portal
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY install.sh /home/portal/install.sh
