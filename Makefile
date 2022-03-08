image_name = openstack-keystone
container_name = openstack-keystone

.PHONY: build
build:
	docker build --force-rm -t $(image_name) .

.PHONY: run
run:
	docker run -itd -p 5000:5000 -p 35357:35357 \
		--hostname keystone --name $(container_name) \
		-v /etc/keystone:/etc/keystone \
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
