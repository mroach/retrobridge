REPO = ghcr.io/mroach/retrobridge
TAG = $(REPO):latest
REVISION = $(shell git rev-parse --short HEAD)

.PHONY: image

image:
	docker build \
		--label "org.opencontainers.image.url=https://github.com/mroach/retrobridge" \
		--label "org.opencontainers.image.revision=$(REVISION)" \
		--label "org.opencontainers.image.created=$(shell date --rfc-3339=seconds)" \
		--label "org.opencontainers.image.licenses=MIT" \
		--label "org.opencontainers.image.authors=git@c.mroach.com" \
		--tag $(REPO) .
