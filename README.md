# K8s Starter

[![Test](https://github.com/omarfawzi/K8s-Starter/actions/workflows/main.yml/badge.svg)](https://github.com/omarfawzi/K8s-Starter/actions/workflows/main.yml)

This project uses **Kind** (Kubernetes in Docker) to create isolated Kubernetes clusters, installs **ArgoCD** using Helm, and manages applications through ArgoCD. This guide provides all the steps to set up, install, and interact with the project.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Steps](#installation-steps)
3. [Configuring Environments](#configuring-environments)
4. [Interacting with the Project](#interacting-with-the-project)
    - [Viewing Logs](#viewing-logs)
    - [Accessing ArgoCD Dashboard](#accessing-argocd-dashboard)
    - [Managing Applications](#managing-applications)
5. [Uninstalling](#uninstalling)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have the following tools installed on your machine:

### Essential Tools

- **Docker**: Required for Kind to create Kubernetes clusters.  
  [Install Docker](https://docs.docker.com/get-docker/)

- **Kind**: Kubernetes in Docker, used for creating local Kubernetes clusters.  
  [Install Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)

- **kubectl**: Command-line tool for interacting with Kubernetes clusters.  
  [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

- **Helm**: Kubernetes package manager, used to install ArgoCD and other Helm charts.  
  [Install Helm](https://helm.sh/docs/intro/install/)

- **argocd CLI**: Command-line tool to interact with the ArgoCD API server.  
  [Install ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

---

## Installation Steps

### Step 1: Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/omarfawzi/K8s-Starter
cd K8s-Starter
```

### Step 2: Set Up the Kubernetes Cluster Using Kind

We support two environments: **Production** and **Staging**. Each environment runs on its own Kind cluster.

- To set up the **Production** cluster:

```bash
make env-production install-argocd
```

- To set up the **Staging** cluster:
```bash
make env-staging install-argocd
```

This will:
1. Create a Kind cluster (`production-cluster` or `staging-cluster`).
2. Install **ArgoCD** in the respective cluster using **Helm**.

### Step 3: Configure and Access ArgoCD

To interact with ArgoCD, you’ll need to log in to the ArgoCD server and retrieve the initial admin password.

#### Step 3.1: Retrieve ArgoCD Admin Password

- For **Production**:
```bash
make env-production get-argocd-password
```

- For **Staging**:
```bash
make env-staging get-argocd-password
```

This will print out the initial ArgoCD admin password.

#### Step 3.2: Log in to ArgoCD

- For **Production**:
```bash
make env-production login-argocd
```

- For **Staging**:
```bash
make env-staging login-argocd
```

This will log you in to the ArgoCD UI. The CLI will output a success message if the login is successful.

---

## Configuring Environments

### Step 1: Switching Environments

You can easily switch between the **Production** and **Staging** environments using the following commands:

- Set environment to **Production**:

```bash
make env-production
```

- Set environment to **Staging**:
```bash
make env-staging
```

This will set the necessary environment variables like `ENVIRONMENT`, `ARGO_PORT`, and `INGRESS_PORT` which are used in various make targets.

### Step 2: Install ArgoCD and Other Dependencies

Once the environment is set, you can run the installation commands as follows:

```bash
make install-argocd
```

This command will create the Kind cluster and install ArgoCD via Helm.

---

## Interacting with the Project

### Viewing Logs

You can view the logs of ArgoCD or any application deployed in the cluster.

#### ArgoCD Server Logs:

- For **Production**:

```bash
make env-production switch-cluster
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server -f
```

- For **Staging**:

```bash
make env-staging switch-cluster
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server -f
```

#### Application Logs:

To view logs for a specific application managed by ArgoCD, use the following command:

```bash
kubectl logs <pod_name> -n <namespace> -f
```

You can find the pod name using:

```bash
kubectl get pods -n <namespace>
```

### Accessing ArgoCD Dashboard

To access the ArgoCD UI, we use **port-forwarding**:

- For **Production**:
```bash
make env-production port-forward-argocd
```
- For **Staging**:
```bash
make env-staging port-forward-argocd
```

After running the command, open your browser and navigate to:

- **Production**: [http://localhost:8080](http://localhost:8080)
- **Staging**: [http://localhost:8081](http://localhost:8081)

You can log in with the **admin** username and the password retrieved earlier.

### Managing Applications

To apply argocd applications set you would need to execute following:

- For **Production**:

```bash
make env-production apply-argocd
```

- For **Staging**:

```bash
make env-staging apply-argocd
```

You can use the ArgoCD CLI or the UI to manage applications. To sync an application from the CLI:

- For **Production**:

```bash
make env-production switch-cluster
argocd app sync <app_name> --insecure
```

- For **Staging**:

```bash
make env-staging switch-cluster
argocd app sync <app_name> --insecure
```

You can also create, delete, or manage applications via the ArgoCD UI.

---

## Uninstalling the Project

To uninstall and clean up the environment:

1. **Delete ArgoCD from the cluster**:

- For **Production**:

  ```
  make env-production uninstall-argocd
  ```

- For **Staging**:

  ```
  make env-staging uninstall-argocd
  ```

2. **Delete the Kind cluster**:

```bash
kind delete cluster --name <cluster-name>
```

3. **Clean up Helm releases**:

```bash
helm uninstall argo-cd -n argocd
```

---

## Troubleshooting

- **ArgoCD UI not accessible**: Make sure the port-forwarding is running. If necessary, check if the ArgoCD server pod is up using `kubectl get pods -n argocd`.
- **Application sync fails**: Check the logs for the application using `kubectl logs` to identify issues. Also, verify the ArgoCD UI for error messages.
- **Kind cluster issues**: If the Kind cluster isn’t starting, ensure Docker is running and that your machine has enough resources.

---

## Architecture

Here’s a high-level architecture diagram of the project setup:

- **Kind**: Creates isolated Kubernetes clusters.
- **Helm**: Installs ArgoCD in the clusters.
- **ArgoCD**: Manages applications and provides GitOps functionality.

---

## Contributing

Feel free to open issues or contribute by creating pull requests for improvements or bug fixes.
