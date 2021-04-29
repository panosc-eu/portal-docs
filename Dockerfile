# syntax=docker/dockerfile:1
FROM ubuntu
RUN apt-get update && apt-get install -y curl sudo
RUN useradd -ms /bin/bash -G sudo portal && \
    usermod -aG sudo portal
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY install.sh /home/portal/install.sh
