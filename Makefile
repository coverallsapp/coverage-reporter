UUID := $(shell id -u)
GUID := $(shell id -g)

compile:
	crystal build src/cli.cr -o dist/coveralls --progress

release_linux:
	docker run --rm -it -v $(shell pwd):/app -w /app  --user $(UUID):$(GUID) crystallang/crystal:latest-alpine \
		crystal build src/cli.cr -o dist/coveralls --release --static --no-debug --progress
	cd dist && strip coveralls && tar -cvzf coveralls-linux.tar.gz coveralls

release_mac:
	crystal build src/cli.cr -o dist/coveralls --release --no-debug --progress
	cd dist && tar -cvzf coveralls-mac.tar.gz coveralls

release: | release_linux release_mac

test:
	crystal spec

lint:
	bin/ameba
