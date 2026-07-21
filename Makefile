.NOTPARALLEL:

COMMIT   :=  $(shell git rev-parse HEAD)
DATE     :=  $(shell date -u +"%Y%m%dT%H%M%S%s")
REPO     :=  $(shell aws ssm get-parameter --name '/iac/system/codebuild/share/ecr/repository/uri' --output text --query 'Parameter.Value' --output text --with-decryption)
REPONAME :=  $(shell echo $(REPO) | cut -d '/' -f 2)
NAME     :=  codebuild-lambda-runner

.PHONY: all
all: build tag
	@echo ">> $(@)"
	@true

.PHONY: build
build: build-arm64
build:
	@echo ">> $(@)"
	@true

.PHONY: build-arm64
build-arm64: test
build-arm64:
	@echo ">> $(@)"
	@podman build --cache-from $(REPO) --layers --platform linux/arm64 --progress plain --tag $(NAME)-arm64 .
# @podman build --cache-from $(REPO) --cache-to $(REPO) --layers --platform linux/arm64 --progress plain --tag $(NAME)-arm64 .

.PHONY: login
login:
	@echo ">> $(@)"
	@aws ecr get-login-password | podman login --username AWS --password-stdin $(REPO)

.PHONY: push
push: push-arm64
push:
	@echo ">> $(@)"
	@true

.PHONY: push-arm64
push-arm64: tag-arm64
push-arm64: untag
push-arm64:
	@echo ">> $(@)"
	@podman push $(REPO):$(COMMIT)-arm64
	@podman push $(REPO):$(DATE)-arm64
	@podman push $(REPO):$(NAME)-arm64

.PHONY: run
run: run-arm64
run:
	@echo ">> $(@)"
	@true

.PHONY: run-arm64
run-arm64:
	@echo ">> $(@)"
	@podman run --interactive --platform linux/arm64 --tty $(NAME)-arm64 bash

.PHONY: tag
tag: tag-arm64
tag:
	@echo ">> $(@)"
	@true

.PHONY: tag-arm64
tag-arm64: build-arm64
tag-arm64:
	@echo ">> $(@)"
	@podman tag $(NAME)-arm64 $(REPO):$(COMMIT)-arm64
	@podman tag $(NAME)-arm64 $(REPO):$(DATE)-arm64
	@podman tag $(NAME)-arm64 $(REPO):$(NAME)-arm64

.PHONY: test
test:
	@echo ">> $(@)"
	@hadolint --failure-threshold warning Containerfile

.PHONY: untag
untag: untag-arm64
untag:
	@echo ">> $(@)"
	@true

.PHONY: untag-arm64
untag-arm64:
	@echo ">> $(@)"
	@-aws ecr batch-delete-image --image-ids imageTag=$(NAME)-arm64 --output json --region us-east-1 --repository-name $(REPONAME)
	@-aws ecr batch-delete-image --image-ids imageTag=$(NAME)-arm64 --output json --region us-west-2 --repository-name $(REPONAME)

.PHONY: xx-install-homebrew
xx-install-homebrew:
	@echo ">> $(@)"
	curl \
		--fail \
		--location 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh' \
		--output 'rootfs/opt/extras/homebrew/install.sh' \
		--proto '=https' \
		--show-error \
		--silent \
		--tlsv1.2
