FROM         ubuntu:focal
MAINTAINER   cqroot "cqroot@outlook.com"

ARG          DEBIAN_FRONTEND=noninteractive
ENV          TZ=Asia/Shanghai
EXPOSE       5000 35357

ENV          OS_USERNAME=admin
ENV          OS_PASSWORD=ADMIN_PASS
ENV          OS_PROJECT_NAME=admin
ENV          OS_USER_DOMAIN_NAME=Default
ENV          OS_PROJECT_DOMAIN_NAME=Default
ENV          OS_AUTH_URL=http://keystone:35357/v3
ENV          OS_IDENTITY_API_VERSION=3

COPY         bootstrap.sh etc/keystone.sql /

RUN          apt-get update && \
             apt-get install -y software-properties-common && \
             add-apt-repository cloud-archive:xena && \
             apt-get install -y \
                 keystone apache2 libapache2-mod-wsgi-py3 python3-pip libmysqlclient-dev python3-openstackclient \
                 netcat mysql-client \
                 telnet net-tools vim \
                 && \
             pip3 --no-cache-dir install mysqlclient && \
             rm -rf /var/lib/apt/lists/* && \
             \
             echo "127.0.0.1       keystone" >> /etc/hosts && \
             echo "ServerName keystone" >> /etc/apache2/apache2.conf && \
             rm -f /etc/keystone/keystone.conf && \
             touch /startup

COPY         etc/keystone.wsgi.conf /etc/apache2/sites-available/keystone.conf

WORKDIR      /root

CMD          ["/bin/sh", "-x", "/bootstrap.sh"]

HEALTHCHECK  --interval=60s --timeout=30s \
             CMD curl -fs http://localhost:5000/v3  2> /dev/null || exit 1; \
                 curl -fs http://localhost:35357/v3 2> /dev/null || exit 1;
