VERSION := $(shell cat VERSION)
REGISTRY := 283535628747.dkr.ecr.us-east-1.amazonaws.com
REPO := $(REGISTRY)/aws-practical/puppy-pics

.PHONY: auth vendor build push

auth:
	@echo "Authing to registry $(REGISTRY)..."
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(REGISTRY)
	@echo "Authed to registry"

install:
	@echo "Installing dependencies..."
	pip3 install -r requirements.txt
	@echo "Dependencies installed"

build:
	@echo "Building Docker image with version $(VERSION)..."
	docker build -t puppy-pics .
	docker build --platform=linux/amd64 -t $(REPO):$(VERSION) -t $(REPO):latest .
	@echo "Docker image built"

push: auth build
	@echo "Pushing Docker image to ECR..."
	docker push $(REPO):$(VERSION)
	docker push $(REPO):latest
	@echo "Docker image pushed"
