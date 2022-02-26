image_name = openstack-keystone
container_name = openstack-keystone

.PHONY: build
build:
	docker build --force-rm -t $(image_name) .

.PHONY: run
run:
	docker run -itd --net=host \
		--hostname keystone --name $(container_name) \
		-e KEYSTONE_CONNECTION=mysql+pymysql://keystone:KEYSTONE_DBPASS@127.0.0.1:3306/keystone \
		-e KEYSTONE_SERVER_IP=127.0.0.1 \
		$(image_name)

.PHONY: exec
exec:
	docker exec -it $(container_name) bash

.PHONY: clean
clean:
	docker rm -f $(container_name);
	docker rmi $(image_name)

.PHONY: log
log:
	docker logs -f $(container_name)

.PHONY: compose-up
compose-up:
	docker-compose up -d

.PHONY: compose-down
compose-down:
	docker-compose down -v
