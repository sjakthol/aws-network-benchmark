SHELL = bash
DOCKER = docker

.PHONY: lib
lib:
	$(RM) cid
	$(RM) -r lib/ && mkdir -p lib/
	$(DOCKER) build -t benchmark-build .
	$(DOCKER) run --cidfile cid --detach benchmark-build sleep inf
	$(DOCKER) cp $$(< cid):/usr/bin/iperf3 lib/
	$(DOCKER) cp $$(< cid):/usr/lib64/libiperf.so.0.0.0 lib/libiperf.so.0
	$(DOCKER) stop $$(< cid)
	$(DOCKER) rm $$(< cid)
	$(RM) cid