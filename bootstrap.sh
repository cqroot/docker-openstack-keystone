#!/bin/bash

if [ -f "/startup" ]; then
    cat > /etc/keystone/keystone.conf << EOF
[DEFAULT]
log_dir = /var/log/keystone

[token]
provider = fernet

[database]
EOF

    if env | grep -qi MYSQL_ROOT_PASSWORD; then
        while ! nc -z ${MYSQL_HOST:-mysql} 3306; do echo 'waiting for mysql'; sleep 3s; done
        mysql -uroot -p$MYSQL_ROOT_PASSWORD -h${MYSQL_HOST:-mysql} </keystone.sql
        echo "connection = mysql+pymysql://keystone:KEYSTONE_DBPASS@${MYSQL_HOST:-mysql}:3306/keystone" >> /etc/keystone/keystone.conf
    else
        if [ ! -n "$KEYSTONE_CONNECTION" ]; then
            KEYSTONE_CONNECTION=sqlite:///keystone.db
        fi
        echo "connection = $KEYSTONE_CONNECTION" >> /etc/keystone/keystone.conf
    fi
    rm -rf /keystone.sql

    su -s /bin/sh -c "keystone-manage db_sync" keystone

    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

    keystone-manage bootstrap --bootstrap-password $OS_PASSWORD \
        --bootstrap-admin-url http://keystone:35357/v3/ \
        --bootstrap-internal-url http://keystone:5000/v3/ \
        --bootstrap-public-url http://keystone:5000/v3/ \
        --bootstrap-region-id RegionOne

    cat > /root/admin-openrc << EOF
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://keystone:35357/v3
export OS_IDENTITY_API_VERSION=3
EOF

    rm -f /startup
fi

apache2ctl -D FOREGROUND