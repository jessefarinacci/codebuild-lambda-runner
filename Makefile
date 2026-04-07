.NOTPARALLEL:

ACC := $(shell aws sts get-caller-identity | jq --raw-output '.Account')
REG := $(ACC).dkr.ecr.us-east-1.amazonaws.com
REP := 00000000-0000-0000-0000-000000000000
TAG := codebuild-lambda-runner-multitool-arm64

all: build tag
	@true

build: test
	@echo ">> $(@)"
	@docker build --file Dockerfile --progress=plain --tag $(TAG) .

run:
	@echo ">> $(@)"
	@docker run --interactive --tty $(TAG) bash

tag:
	@echo ">> $(@)"
	@docker tag $(TAG) $(REG)/$(REP):$(TAG)

test:
	@echo ">> $(@)"
	@hadolint Dockerfile
