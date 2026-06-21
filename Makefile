REGISTRY := ghcr.io
IMAGE := silverstripe-platform/platform-build
VERSION ?= latest

.PHONY: login build push release

login:
ifndef GHCR_USER
	$(error GHCR_USER is not set)
endif
ifndef GHCR_TOKEN
	$(error GHCR_TOKEN is not set)
endif
	@echo "Logging in to GitHub Container Registry..."
	@echo $(GHCR_TOKEN) | docker login $(REGISTRY) -u $(GHCR_USER) --password-stdin

build:
	docker build . -t $(REGISTRY)/$(IMAGE):$(VERSION)
	docker build . -t $(REGISTRY)/$(IMAGE):latest

push:
	docker push $(REGISTRY)/$(IMAGE):$(VERSION)
	docker push $(REGISTRY)/$(IMAGE):latest

release: login build push
