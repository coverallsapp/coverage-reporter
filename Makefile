UUID := $(shell id -u)
GUID := $(shell id -g)
CRYSTAL_VERSION := 1.13.1

build:
	shards build coveralls --progress --error-trace

test:
	crystal spec --order random --error-on-warnings

lint:
	bin/ameba

release_linux:
	docker build . --build-arg CRYSTAL_VERSION=$(CRYSTAL_VERSION) --tag coverage-reporter:1.0
	docker run --rm -t -v $(shell pwd):/app \
		-w /app --user $(UUID):$(GUID) \
		coverage-reporter:1.0 \
		shards build coveralls --production --release --static --no-debug --progress
	cd bin && strip coveralls && tar -cvzf ../dist/coveralls-linux.tar.gz coveralls && cp coveralls ../dist/

release: release_linux

.ONESHELL:
new_version:
	@read -p "New version: " version; \
	@read -p "Brief description: " description; \
	sed -i '' "s/version:.*/version: $${version}/" shard.yml; \
	sed -i '' "s/VERSION = .*/VERSION = \"$${version}\"/" src/coverage_reporter.cr; \
	git add shard.yml src/coverage_reporter.cr; \
	git commit --message "$${version}: $${description}"; \
	git tag --annotate v$${version} --message "$${version}: $${description}"; \
	git push origin master --follow-tags
