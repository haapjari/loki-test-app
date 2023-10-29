KIND_CLUSTER_NAME=loki-test-cluster
IMAGE_TAG=latest
APP_NAME=loki-test-app
LOKI_VERSION=2.9.2

.PHONY: all install-tools create-cluster build-image deploy-app clean

all-kind: install-tools create-cluster deploy-all
	sleep 120 # this is because the container takes a bit to get into "Running" state
	make expose

all-compose: build-image
	docker-compose up -d --force-recreate

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
	docker build -t $(APP_NAME):$(IMAGE_TAG) .

kind-load:
	kind load docker-image $(APP_NAME):$(IMAGE_TAG) --name $(KIND_CLUSTER_NAME)

deploy-all: deploy
	helm repo add grafana https://grafana.github.io/helm-charts
	helm upgrade --install loki grafana/loki-stack -f cfg/loki-values.yaml

deploy: build-image
	kubectl apply -f deployment.yaml

expose:
	kubectl port-forward deployment/loki-test-app 8080:8080 > /dev/null 2>&1 &
	kubectl port-forward service/loki-grafana 3000:80 > /dev/null 2>&1 &

loki-admin-password:
	kubectl get secret loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

clean:
	kind delete cluster --name $(KIND_CLUSTER_NAME)
	docker rmi -f $(APP_NAME):$(IMAGE_TAG)