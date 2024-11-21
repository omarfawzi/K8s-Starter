# Variables
HELM_REPO_URL := https://argoproj.github.io/argo-helm
ARGO_HELM_RELEASE := argo-cd
ARGO_NAMESPACE := argocd

# Initialize ArgoCD Helm Repository
init-argo-repo:
	helm repo add argo $(HELM_REPO_URL)

# Create Production Cluster with Kind and Install ArgoCD
create-cluster-production:
	kind create cluster --name production-cluster --config clusters/production/cluster.yaml
	helm install $(ARGO_HELM_RELEASE) argo/argo-cd -n $(ARGO_NAMESPACE) --create-namespace

# Create Staging Cluster with Kind and Install ArgoCD
create-cluster-staging:
	kind create cluster --name staging-cluster --config clusters/staging/cluster.yaml
	helm install $(ARGO_HELM_RELEASE) argo/argo-cd -n $(ARGO_NAMESPACE) --create-namespace

# Retrieve argocd password, user: admin
get-production-cluster-password:
	@kubectl config use-context kind-production-cluster
	@echo "Password: " && kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

# Retrieve argocd password, user: admin
get-staging-cluster-password:
	@kubectl config use-context kind-staging-cluster
	@echo "Password: " && kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

# Login to ArgoCD in Production Cluster
login-production-cluster:
	@echo "Logging in to ArgoCD production cluster..."
	@kubectl config use-context kind-production-cluster
	@argocd login localhost:8080 --username admin --password $$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d) --insecure

# Login to ArgoCD in Staging Cluster
login-staging-cluster:
	@echo "Logging in to ArgoCD staging cluster..."
	@kubectl config use-context kind-staging-cluster
	@argocd login localhost:8081 --username admin --password $$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d) --insecure

apply-argocd-apps-staging:
	kubectl config use-context kind-staging-cluster
	kubectl apply -f argocd-apps/staging/main.yaml

apply-argocd-apps-production:
	kubectl config use-context kind-production-cluster
	kubectl apply -f argocd-apps/production/main.yaml

ingress-install-production:
	kubectl config use-context kind-production-cluster
	kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

ingress-install-staging:
	kubectl config use-context kind-staging-cluster
	kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

# Start ArgoCD in Production Cluster (Port-Forwarding)
start-production-cluster:
	kubectl config use-context kind-production-cluster
	kubectl port-forward svc/argo-cd-argocd-server -n $(ARGO_NAMESPACE) 8080:80

# Start ArgoCD in Staging Cluster (Port-Forwarding)
start-staging-cluster:
	kubectl config use-context kind-staging-cluster
	kubectl port-forward svc/argo-cd-argocd-server -n $(ARGO_NAMESPACE) 8081:80

start-ingress-production:
	kubectl config use-context kind-production-cluster
	kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 8082:80

start-ingress-staging:
	kubectl config use-context kind-staging-cluster
	kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 8083:80