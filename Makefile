KIND_CLUSTER_NAME=loki-test-cluster
IMAGE_TAG=latest
APP_NAME=loki-test-app

all: install-tools create-cluster deploy
	sleep 30
	make expose

install-tools:
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
	chmod +x ./kind
	sudo mv ./kind /usr/local/bin/kind
	curl -LO "https://dl.k8s.io/release/$(shell curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	chmod +x kubectl
	sudo mv kubectl /usr/local/bin/

create-cluster:
	kind create cluster --name $(KIND_CLUSTER_NAME)

build-image:
	docker build -t docker.io/library/$(APP_NAME):$(IMAGE_TAG) .
	kind load docker-image $(APP_NAME):$(IMAGE_TAG) --name $(KIND_CLUSTER_NAME)

deploy: build-image
	kubectl apply -f deployment.yaml

expose:
	kubectl port-forward deployment/loki-test-app 8080:8080

clean:
	kind delete cluster --name $(KIND_CLUSTER_NAME)
	docker rmi -f $(APP_NAME):$(IMAGE_TAG)

.PHONY: all install-tools create-cluster build-image deploy-app clean
