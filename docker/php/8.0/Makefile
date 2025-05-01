PHP_VERSION=8.0
PHP_IMAGE=$(PHP_VERSION)-fpm-alpine
APP_NAME=stackme
DOCKER_REPO=matthewhartstonge
DOCKER_PLATFORM=linux/amd64

# obtain the latest php version according to upstream
VERSION=$(shell docker run --platform ${DOCKER_PLATFORM} --rm php:${PHP_IMAGE} php -r 'echo PHP_VERSION;')

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Docker Building
pull-base-image: ## pull the latest version of the php base image
	@echo 'Pulling latest version of php:$(PHP_IMAGE)'
	docker pull --platform linux/amd64 php:${PHP_IMAGE}
	$(eval VERSION=$(shell docker run --platform ${DOCKER_PLATFORM} --rm php:${PHP_IMAGE} php -r 'echo PHP_VERSION;'))

build: pull-base-image ## Build the container
	docker build --platform $(DOCKER_PLATFORM) -t $(APP_NAME):$(PHP_VERSION) .

build-nc: pull-base-image ## Build the container without caching
	docker build --platform $(DOCKER_PLATFORM) --no-cache -t $(APP_NAME) .


# Docker tagging
tag: tag-version tag-latest ## Generate container tags for the `{version}` and `latest` tags

tag-latest: build ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker tag $(APP_NAME):$(PHP_VERSION) $(DOCKER_REPO)/$(APP_NAME):latest

tag-version: build ## Generate container `latest` tag
	@echo 'create tag $(VERSION)'
	docker tag $(APP_NAME):$(PHP_VERSION) $(DOCKER_REPO)/$(APP_NAME):$(PHP_VERSION)
	docker tag $(APP_NAME):$(PHP_VERSION) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)


# Docker publish
publish: publish-version publish-latest ## Publish the `{version}` and `latest` tagged containers

publish-latest: tag-latest ## Publish the `latest` tagged container
	@echo 'publish latest to $(DOCKER_REPO)'
	docker push --platform $(DOCKER_PLATFORM) $(DOCKER_REPO)/$(APP_NAME):latest

publish-version: tag-version ## Publish the `{version}` tagged container
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push --platform $(DOCKER_PLATFORM) $(DOCKER_REPO)/$(APP_NAME):$(PHP_VERSION)
	docker push --platform $(DOCKER_PLATFORM) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)


# PHP related info
version: ## Output the current php version
	@echo 'version: $(PHP_IMAGE) ($(VERSION))'
