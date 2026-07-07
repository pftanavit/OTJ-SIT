# Kubernetes

![k8s](https://github.com/user-attachments/assets/3be5f1f2-4a03-4c40-9595-3ccbc7d192ad)

Kubernetes (also known as K8s) is an open-source system for automating deployment, scaling, and management of containerized applications. 

## Kubernetes Components

![k8s-parts](https://github.com/user-attachments/assets/a8068858-1ad3-46f8-b77f-e2dcba41c734)

Kubernetes can be divided into two main layers. The Control Plane and the Data Plane (Worker Nodes). 

### Control Plane Components:

The Control Plane manages the overall state of the cluster and can be considered the __*"brain"*__.

- `kube-apiserver`: The core component server that exposes the Kubernetes HTTP API. Objects can be created via this API.

- `etcd`: Consistent and highly-available key value store for all API server data. Only the `kube-apiserver` communicates directly with `etcd`. All other components must go through the API server to get or modify state.

- `kube-scheduler`: Looks for Pods not yet bound to a node, and assigns each Pod to a suitable node. It decides on which node each application instance should run.

- `kube-controller-manager`: Runs controller processes that continuously monitor the state of the cluster via the API server and make changes attempting to move the current state towards the desired state. 

- `cloud-controller-manager` (optional): Integrates with underlying cloud provider(s).

### Data Plane Component:

The Data Plane (or Worker Plane, Worker Nodes) is the collection of nodes where the actual application containers run. The components run on every node, maintaining running pods and providing the Kubernetes runtime environment.

- `kubelet`: An agent that talks to the API server and ensures that Pods are running, including their containers. It reports the status of these applications and the node via the API.

- `Container Runtime`: Software responsible for running containers. It must implement the Container Runtime Interface (CRI), such as containerd or CRI-O. It runs the applications in containers as instructed by the Kubelet.

- `kube-proxy` (optional): Maintains network rules on nodes to implement Services. Load-balances network traffic between applications.

### Add-on Components:

- `DNS`: For cluster-wide DNS resolution.

- `Web UI`: For cluster management via a web interface (Dashboard).

- `Container Resource Monitoring`: For collecting and storing container metrics.

- `Cluster-level Logging`: For saving container logs to a central log store.

### Appendices:

![extra1](https://github.com/user-attachments/assets/ef06c2e6-52c6-40c6-8e3c-84b5c2690785)

![extra2](https://github.com/user-attachments/assets/7a84b27a-1e5b-429e-83fd-e3da2dcc7719)

![extra3](https://github.com/user-attachments/assets/88651de9-c43c-43a2-81c2-9c36115f2a05)

**Sources**: 
- https://kubernetes.io/docs/concepts/overview/components/

- Kubernetes in Action, Second Edition - Marko Lukša, Kevin Conner