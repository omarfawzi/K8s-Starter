# ===================================================================
# Variables
# ===================================================================

HELM_REPO_URL := https://argoproj.github.io/argo-helm
ARGO_HELM_RELEASE := argo-cd
ARGO_NAMESPACE := argocd
KIND_CLUSTER_CONFIG_DIR := clusters

# ===================================================================
# Helm and ArgoCD Setup
# ===================================================================

## Add ArgoCD Helm repository
helm-repo-add:
	helm repo add argo $(HELM_REPO_URL)

## Install ArgoCD in a specified Kind cluster (production or staging)
install-argocd:
	@echo "Installing ArgoCD in the $(ENVIRONMENT) cluster..."
	kind create cluster --name $(ENVIRONMENT)-cluster --config $(KIND_CLUSTER_CONFIG_DIR)/$(ENVIRONMENT)/cluster.yaml
	helm install $(ARGO_HELM_RELEASE) argo/argo-cd -n $(ARGO_NAMESPACE) --create-namespace

# ===================================================================
# Retrieve ArgoCD Credentials
# ===================================================================

## Retrieve ArgoCD initial admin password from the specified cluster
get-argocd-password:
	@echo "Retrieving ArgoCD password for $(ENVIRONMENT) cluster..."
	@kubectl config use-context kind-$(ENVIRONMENT)-cluster
	@echo "Password: " && kubectl -n $(ARGO_NAMESPACE) get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

# ===================================================================
# ArgoCD Authentication
# ===================================================================

## Login to ArgoCD in the specified cluster
login-argocd:
	@echo "Logging in to ArgoCD $(ENVIRONMENT) cluster..."
	@kubectl config use-context kind-$(ENVIRONMENT)-cluster
	@argocd login localhost:$(ARGO_PORT) --username admin --password $$(kubectl -n $(ARGO_NAMESPACE) get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d) --insecure

# ===================================================================
# ArgoCD Application Management
# ===================================================================

## Apply ArgoCD applications for the specified environment
apply-argocd-templates:
	@echo "Applying ArgoCD apps for $(ENVIRONMENT) cluster..."
	kubectl config use-context kind-$(ENVIRONMENT)-cluster
	kubectl apply -f argocd-templates/$(ENVIRONMENT)/main.yaml

# ===================================================================
# Ingress Setup
# ===================================================================

## Install ingress-nginx for the specified environment
install-ingress:
	@echo "Installing ingress-nginx for $(ENVIRONMENT) cluster..."
	kubectl config use-context kind-$(ENVIRONMENT)-cluster
	kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

# ===================================================================
# Port Forwarding
# ===================================================================

## Start ArgoCD port-forwarding for the specified environment
port-forward-argocd:
	@echo "Starting port-forwarding for ArgoCD $(ENVIRONMENT) cluster..."
	kubectl config use-context kind-$(ENVIRONMENT)-cluster
	kubectl port-forward svc/argo-cd-argocd-server -n $(ARGO_NAMESPACE) 808$(ARGO_PORT):80

## Start ingress-nginx port-forwarding for the specified environment
port-forward-ingress:
	@echo "Starting port-forwarding for ingress-nginx $(ENVIRONMENT) cluster..."
	kubectl config use-context kind-$(ENVIRONMENT)-cluster
	kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 808$(INGRESS_PORT):80

# ===================================================================
# Environment Configuration
# ===================================================================

## Set environment to production
env-production:
	$(eval ENVIRONMENT := production)
	$(eval ARGO_PORT := 80)
	$(eval INGRESS_PORT := 2)

## Set environment to staging
env-staging:
	$(eval ENVIRONMENT := staging)
	$(eval ARGO_PORT := 81)
	$(eval INGRESS_PORT := 3)

# ===================================================================
# Default Targets
# ===================================================================

## Set default environment to production and install ArgoCD
default: env-production install-argocd