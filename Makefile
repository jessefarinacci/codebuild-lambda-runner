.NOTPARALLEL:

COMMIT   :=  $(shell git rev-parse HEAD)
REPO     :=  $(shell aws ssm get-parameter --name '/iac/system/codebuild/share/ecr/repository/uri' --output text --query 'Parameter.Value' --output text --with-decryption)
REPONAME :=  $(shell echo $(REPO) | cut -d '/' -f 2)
NAME     :=  codebuild-lambda-runner

all: build tag
	@true

build: build-arm64
build:
	@true

build-arm64: test
build-arm64:
	@echo ">> $(@)"
	@podman build --cache-from $(REPO) --cache-to $(REPO) --layers --platform linux/arm64 --progress plain --tag $(NAME)-arm64 .

login:
	@echo ">> $(@)"
	@aws ecr get-login-password | podman login --username AWS --password-stdin $(REPO)

push: push-arm64
push:
	@true

push-arm64: tag-arm64
push-arm64: untag
push-arm64:
	@echo ">> $(@)"
	@podman push $(REPO):$(COMMIT)-arm64
	@podman push $(REPO):$(NAME)-arm64

run: run-arm64
run-arm64:
	@echo ">> $(@)"
	@podman run --interactive --platform linux/arm64 --tty $(NAME)-arm64 bash

tag: tag-arm64
tag:
	@true

tag-arm64: build-arm64
	@echo ">> $(@)"
	@podman tag $(NAME)-arm64 $(REPO):$(COMMIT)-arm64
	@podman tag $(NAME)-arm64 $(REPO):$(NAME)-arm64

test:
	@echo ">> $(@)"
	@hadolint --failure-threshold warning Dockerfile

untag: untag-arm64
untag:
	@true

untag-arm64:
	@echo ">> $(@)"
	@-aws ecr batch-delete-image --image-ids imageTag=$(NAME)-arm64 --output json --region us-east-1 --repository-name $(REPONAME)
	@-aws ecr batch-delete-image --image-ids imageTag=$(NAME)-arm64 --output json --region us-west-2 --repository-name $(REPONAME)
