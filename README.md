# Docker OpenStack Keystone

Dockerfile for OpenStack Keystone.

## Docker ENV

| ENV                 | Required | Description     |
| :------------------ | :------- | :-------------- |
| KEYSTONE_CONNECTION |          |                 |
| KEYSTONE_HOST       | yes      | current node ip |
| KEYSTONE_NO_INIT    |          |                 |

## Usage

### Deploy the first keystone node

Change 127.0.0.1 to the ip of your node:

```bash
docker run -itd --net=host --hostname keystone --name openstack-keystone \
    -v /etc/keystone:/etc/keystone \
    -e KEYSTONE_CONNECTION=mysql+pymysql://keystone:KEYSTONE_DBPASS@127.0.0.1:3306/keystone \
    -e KEYSTONE_HOST=127.0.0.1 \
    openstack-keystone
```

### Deploy the remaining nodes

Copy the `/etc/keystone` directory of the first node to other nodes. Change 127.0.0.1 to the ip of your node:

```bash
docker run -itd --net=host --hostname keystone --name openstack-keystone \
    -v /etc/keystone:/etc/keystone \
    -e KEYSTONE_HOST=127.0.0.1 \
    -e KEYSTONE_NO_INIT=1 \
    openstack-keystone
```
