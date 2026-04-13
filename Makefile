.NOTPARALLEL:

ACC := $(shell aws sts get-caller-identity | jq --raw-output '.Account')
REG := $(ACC).dkr.ecr.us-east-1.amazonaws.com
REP := 00000000-0000-0000-0000-000000000000
TAG := codebuild-lambda-runner
PLT := linux/amd64,linux/arm64

all: build tag
	@true

build: test
	@echo ">> $(@)"
	@docker build --file Dockerfile --progress=plain --tag $(TAG) .

buildx: test
	@echo ">> $(@)"
	@docker buildx build --platform $(PLT) --tag $(TAG) .

login:
	@echo ">> $(@)"
	@aws ecr get-login-password | docker login --username AWS --password-stdin $(REG)/$(REP)

push: tag
	@echo ">> $(@)"
	@docker push $(REG)/$(REP):$(TAG)

pushx: buildx
	@echo ">> $(@)"
	@docker buildx build --platform $(PLT) --push --tag $(REG)/$(REP):$(TAG) .

run:
	@echo ">> $(@)"
	@docker run --interactive --tty $(TAG) bash

tag: build
	@echo ">> $(@)"
	@docker tag $(TAG) $(REG)/$(REP):$(TAG)

test:
	@echo ">> $(@)"
	@hadolint Dockerfile
