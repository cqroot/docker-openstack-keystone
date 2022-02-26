FROM         debian:stable-20220125-slim
MAINTAINER   cqroot "cqroot@outlook.com"

EXPOSE       5000 35357

ENV          OS_USERNAME=admin
ENV          OS_PASSWORD=ADMIN_PASS
ENV          OS_PROJECT_NAME=admin
ENV          OS_USER_DOMAIN_NAME=Default
ENV          OS_PROJECT_DOMAIN_NAME=Default
ENV          OS_AUTH_URL=http://keystone:35357/v3
ENV          OS_IDENTITY_API_VERSION=3

COPY         bootstrap.sh etc/keystone.sql /
COPY         etc/sources.list /etc/apt/sources.list

RUN          apt-get update && \
             apt-get install -y \
                 libssl-dev python3 python3-pip apache2 libapache2-mod-wsgi-py3 netcat && \
             pip install -U pip -i https://pypi.tuna.tsinghua.edu.cn/simple && \
             pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple \
                 pbr==3.1.1 \
                 WebOb==1.7.1 \
                 Flask==1.1.4 \
                 Flask-RESTful==0.3.5 \
                 MarkupSafe==2.0.1 \
                 cryptography==2.7 \
                 SQLAlchemy==1.3.0 \
                 sqlalchemy-migrate==0.13.0 \
                 stevedore==3.0.0 \
                 passlib==1.7.0 \
                 python-keystoneclient==3.22.0 \
                 keystonemiddleware==7.0.0 \
                 bcrypt==3.1.3 \
                 scrypt==0.8.0 \
                 greenlet==0.4.17 \
                 oslo.cache==1.26.0 \
                 oslo.config==6.8.0 \
                 oslo.context==2.22.0 \
                 oslo.messaging==5.29.0 \
                 oslo.db==6.0.0 \
                 oslo.i18n==3.20.0 \
                 oslo.log==3.44.0 \
                 oslo.middleware==3.31.0 \
                 oslo.policy==3.7.0 \
                 oslo.serialization==2.25.0 \
                 oslo.upgradecheck==1.3.0 \
                 oslo.utils==4.5.0 \
                 oauthlib==0.6.2 \
                 pysaml2==7.1.1 \
                 PyJWT==1.6.1 \
                 dogpile.cache==1.0.2 \
                 jsonschema==3.2.0 \
                 pycadf==1.1.0 \
                 msgpack==0.5.0 \
                 osprofiler==1.4.0 \
                 pytz==2013.6 \
                 python-openstackclient==5.7.0 \
                 PyMySQL==1.0.2 \
                 keystone==20.0.0 \
             && \
             sed -i 's/^Include ports.conf$/# Include ports.conf/g' apache2.conf && \
             echo "ServerName keystone" >> /etc/apache2/apache2.conf && \
             groupadd keystone && useradd keystone -d /home/keystone -g keystone && \
             mkdir -p /etc/keystone /var/log/keystone /home/keystone && \
             chown keystone:keystone /var/log/keystone && \
             rm -rf /var/lib/apt/lists/* && \
             touch /startup

COPY         etc/keystone.wsgi.conf /etc/apache2/sites-enabled/keystone.conf

WORKDIR      /root

CMD          ["/bin/sh", "-x", "/bootstrap.sh"]

HEALTHCHECK  --interval=60s --timeout=30s \
             CMD nc -z localhost 5000 || exit 1; \
                 nc -z localhost 35357 || exit 1;
