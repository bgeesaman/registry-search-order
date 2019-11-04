ACCOUNT := bradgeesaman
SERVICE := registry-search-order
IMAGE := $(ACCOUNT)/$(SERVICE)
TAG := latest
 

help:
	@echo "Help"
build:
	$(info Make: Building "$(TAG)" tagged images.)
	@docker build -t $(IMAGE):$(TAG) .
run:
	$(info Make: Running "$(TAG)" tagged image.)
	@docker run --rm -it $(IMAGE):$(TAG)

push:
	$(info Make: Pushing "$(TAG)" tagged image.)
	@docker push $(IMAGE):$(TAG)
 
clean:
	@docker system prune --volumes --force
 
login:
	$(info Make: Login to Docker Hub.)
	@docker login
