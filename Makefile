ENV ?= dev
PROJECT ?= your-gcp-project
REGION ?= us-central1
CLUSTER ?= otel-$(ENV)

tf-init:
	cd terraform/envs/$(ENV) && terraform init

tf-apply:
	cd terraform/envs/$(ENV) && terraform apply -auto-approve

tf-destroy:
	cd terraform/envs/$(ENV) && terraform destroy -auto-approve

kube-auth:
	gcloud container clusters get-credentials $(CLUSTER) \
	  --region $(REGION) --project $(PROJECT)

install-observability:
	helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
	helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
	helm upgrade --install otel-agent open-telemetry/opentelemetry-collector \
	  -n observability --create-namespace -f helm/otel-agent-values.yaml
	helm upgrade --install otel-gateway open-telemetry/opentelemetry-collector \
	  -n observability -f helm/otel-gateway-values.yaml
	helm upgrade --install jaeger jaegertracing/jaeger \
	  -n observability --set query.enabled=true --set collector.enabled=true \
	  --set agent.enabled=false --set storage.type=memory
	kubectl apply -f helm/instrumentation.yaml

deploy-apps:
	kubectl apply -f k8s/backend.yaml
	kubectl apply -f k8s/frontend.yaml

all: tf-init tf-apply kube-auth install-observability deploy-apps

