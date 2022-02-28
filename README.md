# Docker OpenStack Keystone

Dockerfile for OpenStack Keystone.

## Docker ENV

| ENV                 | Required | Description     |
| :------------------ | :------- | :-------------- |
| KEYSTONE_CONNECTION |          |                 |
| KEYSTONE_HOST       | yes      | current node ip |
| KEYSTONE_NO_INIT    |          |                 |

## Usage

### Deploy mysql and keystone

You can use docker compose to deploy `mysql` and `keystone` on one node.

```bash
make compose_up
```

### Deploy the first keystone node

```bash
docker run -itd --net=host --hostname keystone --name openstack-keystone \
    -e KEYSTONE_CONNECTION='mysql+pymysql://MYSQL_USER:MYSQL_PASSWORD@MYSQL_IP:MYSQL_PORT/keystone' \
    -e KEYSTONE_HOST=YOUR_IP \
    openstack-keystone
```

### Deploy the remaining nodes

Copy the `/etc/keystone` directory of the first node to other nodes.

```bash
docker run -itd --net=host --hostname keystone --name openstack-keystone \
    -v /etc/keystone:/etc/keystone \
    -e KEYSTONE_HOST=YOUR_IP \
    -e KEYSTONE_NO_INIT=1 \
    openstack-keystone
```
