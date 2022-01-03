image_name = openstack-keystone

.PHONY: build
build:
	docker build --force-rm -t $(image_name) .

.PHONY: run
run:
	docker run -itd \
		-p 5000:5000 -p 35357:35357 \
		--hostname keystone --name keystone \
		-e KEYSTONE_CONNECTION=mysql+pymysql://keystone:KEYSTONE_DBPASS@127.0.0.1:3306/keystone \
		-e MYSQL_ROOT_PASSWORD=MYSQL_PASS \
		-e MYSQL_HOST=127.0.0.1 \
		$(image_name)

.PHONY: exec
exec:
	docker exec -it keystone bash

.PHONY: clean
clean:
	docker rm -f keystone;
	docker rmi $(image_name)

.PHONY: log
log:
	docker logs -f keystone

.PHONY: compose-up
compose-up:
	docker-compose up -d

.PHONY: compose-down
compose-down:
	docker-compose down -v
