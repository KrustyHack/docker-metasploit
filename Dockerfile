# Docker container with metasploit.
#
# Use Kali Linux base image (1.0.9)

FROM debian:wheezy
MAINTAINER KrustyHack krustyhack@gmail.com

RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install git build-essential libreadline-dev libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev openjdk-7-jre subversion autoconf postgresql pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev ruby1.9.3 ruby-dev nmap

RUN gem install wirble sqlite3 bundler

RUN cd /opt/ && git clone git://github.com/rapid7/metasploit-framework.git && cd metasploit-framework/ && bundle install
RUN bash -c 'for MSF in $(ls msf*); do ln -s /opt/metasploit-framework/$MSF /usr/bin/$MSF;done'
ADD files/metasploit/database.yml /opt/metasploit-framework/config/database.yml
RUN bash -c "echo export MSF_DATABASE_CONFIG=/opt/metasploit-framework/config/database.yml >> /etc/profile
source /etc/profile"

RUN psql -c "CREATE USER msf WITH PASSWORD 'msf';"
RUN psql -c "CREATE DATABASE msf OWNER msf;"
RUN psql -c "GRANT ALL ON msf TO msf;"

VOLUME ["/usr/share/metasploit-framework"]