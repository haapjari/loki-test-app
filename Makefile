KIND_CLUSTER_NAME=loki-test-cluster
IMAGE_TAG=latest
APP_NAME=loki-test-app
LOKI_VERSION=2.9.2

all: install-tools create-cluster deploy deploy-loki deploy-grafana
	sleep 120 # this is because the container takes a bit to get into "Running" state
	make expose

install-tools:
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
	chmod +x ./kind
	sudo mv ./kind /usr/local/bin/kind
	curl -LO "https://dl.k8s.io/release/$(shell curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	chmod +x kubectl
	sudo mv kubectl /usr/local/bin/
	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

create-cluster:
	kind create cluster --name $(KIND_CLUSTER_NAME)

build-image:
	docker build -t docker.io/library/$(APP_NAME):$(IMAGE_TAG) .
	kind load docker-image $(APP_NAME):$(IMAGE_TAG) --name $(KIND_CLUSTER_NAME)

deploy-loki:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm upgrade --install my-loki ./custom-loki --set podAntiAffinity="none"
	helm upgrade --install my-promtail grafana/promtail --version 6.15.3 --set podAntiAffinity="none"

deploy-grafana:
	kubectl create namespace grafana
	kubectl apply -f grafana.yaml --namespace=grafana


deploy: build-image
	kubectl apply -f deployment.yaml

expose:
	kubectl port-forward deployment/loki-test-app 8080:8080 > /dev/null 2>&1 &
	kubectl port-forward service/grafana 3000:3000 --namespace=grafana > /dev/null 2>&1 &

clean:
	kind delete cluster --name $(KIND_CLUSTER_NAME)
	docker rmi -f $(APP_NAME):$(IMAGE_TAG)

.PHONY: all install-tools create-cluster build-image deploy-app clean
