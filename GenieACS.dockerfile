# GenieACS v1.2 Dockerfile #
##############################

# Dockerfile of node:8-stretch here: https://github.com/nodejs/docker-node/blob/526c6e618300bdda0da4b3159df682cae83e14aa/8/stretch/Dockerfile
FROM node:10-buster
LABEL maintainer="acsdesk@protonmail.com"

RUN apt-get update && apt-get install -y sudo apt-transport-https apt-utils supervisor git
RUN mkdir -p /var/log/supervisor

#sudo npm install -g --unsafe-perm genieacs@1.2.0
WORKDIR /opt
RUN git clone https://github.com/genieacs/genieacs.git -b master
WORKDIR /opt/genieacs
RUN npm install
RUN npm run build

RUN useradd --system --no-create-home --user-group genieacs
#RUN mkdir /opt/genieacs
RUN mkdir /opt/genieacs/ext
RUN chown genieacs:genieacs /opt/genieacs/ext

ADD genieacs.env /opt/genieacs/genieacs.env
RUN chown genieacs:genieacs /opt/genieacs/genieacs.env
RUN chmod 600 /opt/genieacs/genieacs.env

RUN mkdir /var/log/genieacs
RUN chown genieacs:genieacs /var/log/genieacs

ADD genieacs.logrotate /etc/logrotate.d/genieacs

WORKDIR /opt
RUN git clone https://github.com/DrumSergio/genieacs-services -b 1.2
RUN cp genieacs-services/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN cp genieacs-services/run_with_env.sh /etc/supervisor/conf.d/run_with_env.sh

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
