UUID := $(shell id -u)
GUID := $(shell id -g)
CRYSTAL_VERSION := 1.7.2

compile:
	crystal build src/cli.cr -o dist/coveralls --progress

release_linux:
	docker build . --tag coverage-reporter:1.0
	docker run --rm -t -v $(shell pwd):/app \
		-w /app --user $(UUID):$(GUID) \
		coverage-reporter:1.0 \
		crystal build src/cli.cr -o dist/coveralls --release --static --no-debug --progress
	cd dist && strip coveralls && tar -cvzf coveralls-linux.tar.gz coveralls

release_mac:
	crystal build src/cli.cr -o dist/coveralls --release --no-debug --progress
	cd dist && strip coveralls && tar -cvzf coveralls-mac.tar.gz coveralls

release: | release_linux release_mac

test:
	crystal spec --order random --error-on-warnings

lint:
	bin/ameba
