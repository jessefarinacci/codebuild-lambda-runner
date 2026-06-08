.NOTPARALLEL:

ACC := $(shell aws sts get-caller-identity | jq --raw-output '.Account')
REG := $(ACC).dkr.ecr.us-east-1.amazonaws.com
REP := 00000000-0000-0000-0000-000000000000
TAG := codebuild-lambda-runner

all: build tag
	@true

# build: build-amd64
build: build-arm64
build:
	@true

# build-amd64: test
# build-amd64:
# 	@echo ">> $(@)"
# 	@podman build --platform linux/amd64 --progress plain --tag $(TAG)-amd64 .

build-arm64: test
build-arm64:
	@echo ">> $(@)"
	@podman build --platform linux/arm64 --progress plain --tag $(TAG)-arm64 .

login:
	@echo ">> $(@)"
	@aws ecr get-login-password | podman login --username AWS --password-stdin $(REG)/$(REP)

# push: push-amd64
push: push-arm64
push:
	@true

# push-amd64: tag-amd64
# push-amd64:
# 	@echo ">> $(@)"
# 	@podman push $(REG)/$(REP):$(TAG)-amd64

push-arm64: tag-arm64
push-arm64:
	@echo ">> $(@)"
	@podman push $(REG)/$(REP):$(TAG)-arm64

run: run-arm64
run-arm64:
	@echo ">> $(@)"
	@podman run --interactive --platform linux/arm64 --tty $(TAG)-arm64 bash

# tag: tag-amd64
tag: tag-arm64
tag:
	@true

# tag-amd64: build-amd64
# 	@echo ">> $(@)"
# 	@podman tag $(TAG)-amd64 $(REG)/$(REP):$(TAG)-amd64

tag-arm64: build-arm64
	@echo ">> $(@)"
	@podman tag $(TAG)-arm64 $(REG)/$(REP):$(TAG)-arm64

test:
	@echo ">> $(@)"
	@-hadolint Dockerfile
