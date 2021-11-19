build:
	docker build --force-rm -t openstack-keystone .

run:
	docker run -itd \
		-p 5000:5000 -p 35357:35357 \
		--hostname keystone --name keystone \
		-e KEYSTONE_CONNECTION=mysql+pymysql://keystone:KEYSTONE_DBPASS@172.30.10.63:3306/keystone \
		-e MYSQL_ROOT_PASSWORD=MYSQL_PASS \
		-e MYSQL_HOST=127.0.0.1 \
		openstack-keystone

exec:
	docker exec -it keystone bash

clean:
	docker rm -f keystone;
	docker rmi openstack-keystone

log:
	docker logs -f keystone

compose_up:
	docker-compose up -d

compose_down:
	docker-compose down -v
