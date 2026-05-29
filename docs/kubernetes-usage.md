# Kubernetes (k8s) Usage

This document provides a guide to interacting with Kubernetes clusters, focusing on `kubectl` (the Kubernetes command-line tool) and common helper utilities.

## Overview

[Kubernetes](https://kubernetes.io/) (commonly stylized as k8s) is an open-source system for automating deployment, scaling, and management of containerized applications.

## `kubectl`: The Kubernetes CLI

`kubectl` is the primary command-line tool for running commands against Kubernetes clusters. It allows you to deploy applications, inspect and manage cluster resources, and view logs.

### Installation

*   **Homebrew (macOS)**:
    ```sh
    brew install kubectl
    ```
*   **Official Guides**: For other operating systems or specific versions, refer to the [official Kubernetes documentation on installing `kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

Installation might be managed by `chezmoi` if `kubectl` is part of your standard toolset.

### Configuration (`kubeconfig`)

`kubectl` uses a configuration file, typically located at `~/.kube/config`, to store cluster access information (server endpoints, user credentials, namespaces, contexts).

*   **Multiple Clusters**: The `kubeconfig` file can define multiple clusters and contexts.
*   **Context Switching**: Use `kubectl config use-context <context_name>` to switch between defined contexts.
*   **Environment Variable**: You can specify a different kubeconfig file by setting the `KUBECONFIG` environment variable:
    ```sh
    export KUBECONFIG=~/.kube/custom-config:~/.kube/another-config
    ```
*   **Security**: Kubeconfig files can contain sensitive credentials. 
    *   Avoid committing them directly to public repositories.
    *   Consider using tools that dynamically generate or fetch credentials (e.g., `aws eks update-kubeconfig` for Amazon EKS, `gcloud container clusters get-credentials` for GKE).
    *   If you must store parts of a kubeconfig managed by `chezmoi`, ensure sensitive fields are templated and sourced from a secrets manager like 1Password (see `docs/1password-usage.md`).

## Common `kubectl` Commands

*   **Cluster Information & Contexts**:
    *   `kubectl cluster-info`: Display endpoint information about the master and services.
    *   `kubectl config get-contexts`: List available contexts.
    *   `kubectl config current-context`: Display the current context.
    *   `kubectl config use-context <context_name>`: Switch to a different context.

*   **Viewing Resources**:
    *   `kubectl get nodes`: List all nodes in the cluster.
    *   `kubectl get pods [-n <namespace>] [-o wide]`: List pods in a namespace (add `-A` or `--all-namespaces` for all).
    *   `kubectl get services [-n <namespace>]`: List services.
    *   `kubectl get deployments [-n <namespace>]`: List deployments.
    *   `kubectl get namespaces`: List all namespaces.
    *   `kubectl describe pod <pod_name> [-n <namespace>]`: Show detailed information about a pod.
    *   `kubectl describe node <node_name>`: Show detailed information about a node.

*   **Interacting with Pods**:
    *   `kubectl logs <pod_name> [-n <namespace>] [-c <container_name>]`: Print the logs for a container in a pod.
        *   `kubectl logs -f <pod_name>`: Follow log output.
    *   `kubectl exec -it <pod_name> [-n <namespace>] [-c <container_name>] -- <command>`: Execute a command in a container.
        *   Example (get a shell): `kubectl exec -it my-pod -- /bin/sh`
    *   `kubectl cp <file_path> <pod_name>:<path_in_pod>`: Copy files and directories to and from containers.

*   **Managing Applications**:
    *   `kubectl apply -f <filename.yaml_or_directory>`: Apply a configuration to a resource by filename or stdin.
    *   `kubectl delete -f <filename.yaml>`: Delete resources defined in a file.
    *   `kubectl delete pod <pod_name> [-n <namespace>]`: Delete a pod.
    *   `kubectl scale deployment <deployment_name> --replicas=<count>`: Scale a deployment.

*   **Port Forwarding**:
    *   `kubectl port-forward <pod_name_or_service/service_name> <local_port>:<remote_port>`: Forward one or more local ports to a pod or service.
        *   Example: `kubectl port-forward svc/my-service 8080:80`

## Helper Tools & Ecosystem

*   **[k9s](https://k9scli.io/)**: A terminal-based UI to interact with your Kubernetes clusters. Highly recommended for easier navigation and management.
    *   Installation (Homebrew): `brew install k9s`
*   **[kubectx + kubens](https://github.com/ahmetb/kubectx)**: Tools to switch between Kubernetes contexts (`kubectx`) and namespaces (`kubens`) more easily.
    *   Installation (Homebrew): `brew install kubectx`
*   **[Helm](https://helm.sh/)**: The package manager for Kubernetes. Helps you manage Kubernetes applications through Helm Charts.
    *   Installation (Homebrew): `brew install helm`
*   **[Lens](https://k8slens.dev/)**: A popular open-source Kubernetes IDE for managing clusters.
*   **[Stern](https://github.com/stern/stern)**: Multi-pod and container log tailing for Kubernetes.

## Resources

*   **Official Kubernetes Documentation**: [https://kubernetes.io/docs/](https://kubernetes.io/docs/)
*   **`kubectl` Cheat Sheet**: [https://kubernetes.io/docs/reference/kubectl/cheatsheet/](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
*   **`kubectl` Command Reference**: [https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
*   **k9s**: [https://k9scli.io/](https://k9scli.io/)
*   **kubectx + kubens**: [https://github.com/ahmetb/kubectx](https://github.com/ahmetb/kubectx)
*   **Helm**: [https://helm.sh/docs/](https://helm.sh/docs/)

This document provides a starting point. Kubernetes is a complex system; refer to the official documentation and tool-specific guides for detailed information.
