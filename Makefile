VERSION ?= latest

DOCKERFILE := Dockerfile
IMAGE_NAME := crystal-xbuild

.PHONY: build
build: $(DOCKERFILE)
	docker build -t ${IMAGE_NAME}:${VERSION} -f ${DOCKERFILE} .

.PHONY: run
run: $(DOCKERFILE)
	docker run -it --rm -u $$(id -u):$$(id -g) -v .:/app -w /app ${IMAGE_NAME}:${VERSION} sh -i

.PHONY: ubuntu
ubuntu:
	docker run -it --rm --platform linux/amd64 -v .:/app -w /app ubuntu:24.04 bash -i
