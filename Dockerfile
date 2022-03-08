FROM         debian:stable-20220125-slim
MAINTAINER   cqroot "cqroot@outlook.com"

ENV          TZ=Asia/Shanghai
EXPOSE       5000 35357

COPY         bootstrap.sh /
COPY         etc/sources.list /etc/apt/sources.list

RUN          apt-get update && \
             apt-get install -y \
                 libssl-dev python3 python3-pip apache2 libapache2-mod-wsgi-py3 && \
             pip install -U pip -i https://pypi.tuna.tsinghua.edu.cn/simple && \
             pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple \
                 PyMySQL==1.0.2 \
                 keystone==20.0.0 \
             && \
             sed -i 's/^Include ports.conf$/# Include ports.conf/g' /etc/apache2/apache2.conf && \
             groupadd keystone && useradd keystone -d /home/keystone -g keystone && \
             mkdir -p /etc/keystone /var/log/keystone /home/keystone && \
             chown keystone:keystone /var/log/keystone && \
             rm -rf /var/lib/apt/lists/* && \
             touch /startup

COPY         etc/keystone.wsgi.conf /etc/apache2/sites-enabled/keystone.conf

WORKDIR      /root

CMD          ["/bin/sh", "-x", "/bootstrap.sh"]
