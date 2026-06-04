IMAGE_NAME ?= project-devops-deploy
IMAGE_TAG ?= latest
CONTAINER_NAME ?= project-devops-deploy
APP_PORT ?= 8080
MANAGEMENT_PORT ?= 9090
SPRING_PROFILE ?= prod

test:
	./gradlew test

start: run

run:
	./gradlew bootRun

update-gradle:
	./gradlew wrapper --gradle-version 9.2.1

update-deps:
	./gradlew refreshVersions

install:
	./gradlew dependencies

build:
	./gradlew build

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

docker-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

docker-run:
	docker run --rm -it \
		--name $(CONTAINER_NAME) \
		-p $(APP_PORT):8080 \
		-p $(MANAGEMENT_PORT):9090 \
		-e SPRING_PROFILES_ACTIVE=$(SPRING_PROFILE) \
		$(IMAGE_NAME):$(IMAGE_TAG)

docker-run-dev:
	docker run --rm -it \
		--name $(CONTAINER_NAME) \
		-p $(APP_PORT):8080 \
		-p $(MANAGEMENT_PORT):9090 \
		-e SPRING_PROFILES_ACTIVE=dev \
		$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: test start run update-gradle update-deps install build lint lint-fix \
	docker-build docker-run docker-run-dev
