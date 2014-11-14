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
RUN apt-get -y install git build-essential libreadline-dev libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev openjdk-7-jre subversion autoconf postgresql pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev ruby1.9.3 ruby-dev nmap supervisor

RUN gem install wirble sqlite3 bundler

### POSTGRESQL ###
RUN /etc/init.d/postgresql start
RUN /etc/init.d/postgresql status

USER postgres
RUN /etc/init.d/postgresql start &&\
    psql -c "CREATE USER msf WITH PASSWORD 'msf';" &&\
    psql -c "CREATE DATABASE \"msf\" OWNER msf;"
### POSTGRESQL ###

USER root

### SUPERVISORD ###
ADD files/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD files/postgresql/start.sh /root/postgresql/start.sh
RUN chmod +x /root/postgresql/start.sh
### SUPERVISORD ###

### METASPLOIT ###
RUN cd /opt/ && git clone git://github.com/rapid7/metasploit-framework.git && cd metasploit-framework/ && bundle install
RUN cd /opt/metasploit-framework && bash -c 'for MSF in $(ls msf*); do ln -s /opt/metasploit-framework/$MSF /usr/bin/$MSF;done'
ADD files/metasploit/database.yml /opt/metasploit-framework/config/database.yml
RUN bash -c "echo export MSF_DATABASE_CONFIG=/opt/metasploit-framework/config/database.yml >> /etc/profile"
### METASPLOIT ###

VOLUME ["/usr/share/metasploit-framework"]

CMD /usr/bin/supervisord && service metasploit start && msfconsole