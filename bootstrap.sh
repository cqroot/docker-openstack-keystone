#!/bin/bash

init_keystone() {
    cat > /etc/keystone/keystone.conf << EOF
[DEFAULT]
log_dir = /var/log/keystone

[token]
provider = fernet

[database]
EOF

    PUBLIC_PORT=${PUBLIC_PORT:-5000}
    ADMIN_PORT=${ADMIN_PORT:-35357}
    KEYSTONE_CONNECTION=${KEYSTONE_CONNECTION:-sqlite:////keystone.db}

    echo "connection = $KEYSTONE_CONNECTION" >> /etc/keystone/keystone.conf

    keystone-manage db_sync

    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

    keystone-manage bootstrap --bootstrap-password $OS_PASSWORD \
        --bootstrap-admin-url http://${KEYSTONE_HOST}:${ADMIN_PORT}/v3/ \
        --bootstrap-internal-url http://${KEYSTONE_HOST}:${PUBLIC_PORT}/v3/ \
        --bootstrap-public-url http://${KEYSTONE_HOST}:${PUBLIC_PORT}/v3/ \
        --bootstrap-region-id RegionOne
}

if [ -f "/startup" ]; then
    if !(env | grep -qi KEYSTONE_HOST); then
        KEYSTONE_HOST=${KEYSTONE_HOST:-$HOSTNAME}
    fi

    if !(env | grep -qi OS_PASSWORD); then
        OS_PASSWORD=ADMIN_PASS
    fi

    if !(env | grep -qi KEYSTONE_NO_INIT); then
        init_keystone
    else
        chown -R keystone:keystone /etc/keystone
    fi

    cat > /root/admin-openrc << EOF
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://${KEYSTONE_HOST}:${ADMIN_PORT}/v3
export OS_IDENTITY_API_VERSION=3
EOF
    echo "ServerName ${KEYSTONE_HOST}" >> /etc/apache2/apache2.conf

    rm -f /startup
fi

apache2ctl -D FOREGROUND
