# Kubernetes Network

Kubernetes networking relies on a flat, model-driven architecture where every Pod gets its own unique, routable IP address. This eliminates the need for Network Address Translation (NAT) and enables seamless, direct communication between containers, Pods, Services, and external networks across the cluster.

## Container-to-Container

When creating a Pod, the application containers do not start immediately. Instead, an infrastructure container called the `pause` container is run first.

The main purpose of the `pause` container is to request a network namespace and IP address from the kernel then go to sleep. It holds this namespace open. When the actual application containers are spun up, they are instructed by the container runtime to join the `pause` container's network namespace.

Because the containers share the exact same namespace, they share the same local loopback interface (`lo`). They share the same network namespace, IP address, and port space. They can simply talk to each other over `localhost`.

## Pod-to-Pod

Communicating between Pods on different nodes. This falls under the CNI (Container Network Interface). The CNI creates a `veth` (virtual ethernet) pair for every Pod. It acts as a virtual patch cable. One end is connected inside the Pod, the other sits in the Node's root network namespace. 

- **Overlay Networks** (e.g., Flannel VXLAN, Calico VXLAN): When Pod A pings Pod B, the packet travels down the `veth` cable to the Node. The CNI encapsulates the packet inside an outer wrapper (like a standard UDP/VXLAN packet) and ships it across the physical network. Node 2 receives it, the CNI strips off the wrapper, and drops the raw packet down Pod B's `veth` cable.

- **Routing/eBPF Networks** (e.g., Cilium, Calico BGP): Packets are routed directly via the Node's routing table or optimized using eBPF, completely bypassing encapsulation wrappers and traditional Linux bridges to minimize latency.

## Pod-to-Service

When communicating between different microservices, hardcoding individual Pod IPs is impossible because Pods are ephemeral, they frequently die, restart and change IPs. Kubernetes introduces a permanent networking abstraction called a **Service**. To bridge the gap between permanent Services and temporary Pods, Kubernetes relies on a combination of **CoreDNS**, **Label Selectors**, and EndpointSlices.

### CoreDNS & The Service Name
Instead of memorizing a virtual IP address, an application container inside a Pod simply makes a network request using the human-readable name of the destination Service. (`fetch('http://my-backend-service:8080')`). When this request fires, the Pod reaches out to **CoreDNS**, the built-in cluster DNS server. CoreDNS looks up `my-backend-service`, matches it to its corresponding virtual IP (ClusterIP), and returns that IP back to the calling Pod.

### Label Selectors & The Service YAML
A Service knows which specific Pods belong to its routing pool by using Labels and Selectors. Labels are key/value pairs that are attached to objects such as Pods. This allows Pods to be scaled up or down seamlessly without breaking the Service definition.

### The EndpointSlice Registry & `kube-proxy`
When applying the Service YAML, Kubernetes control plane automatically generates a companion system object called an **EndpointSlice**. The EndpointSlice controller continuously monitors the cluster for healthy Pods matching the Service's label selector and maintains a live list of their raw, private IPs. 

A network agent called `kube-proxy` runs on every Node. It watches the Kubernetes API for changes to these Services and EndpointSlices. It takes the live list and writes programming rules directly into the Node's Linux kernel (using `iptables`, `IPVS`, `eBPF`). When the frontend's traffic hits the virtual ClusterIP, the kernel hijacks the packet, load-balances it against the active EndpointSlice list, executes **Destination NAT (DNAT)** to rewrite the destination IP, and routes it directly to a healthy destination Pod. 


## External-to-Internal

Getting internet traffic into cluster involves translating traditional web traffic into Kubernetes-native routing. 

1. **The External Load Balancer**: The cloud provider (AWS, GCP, Azure) sends public traffic to a physical or cloud-managed Load Balancer. This Load Balancer is managed by the Kubernetes Cloud Controller Manager to forward traffic to a specific `NodePort` assigned across the worker Nodes.

2. **The Ingress Controller**: Once traffic hits the `NodePort`, it is routed to an Ingress Controller Pod (such as NGINX, Traefik, or HAProxy). The Ingress Controller acts as a Layer 7 reverse proxy.

3. **Bypassing the ClusterIP**: The Ingress Controller terminates/decrypts the HTTPS traffic, evaluates the HTTP headers, and matches them against your defined Ingress path rules. To optimize performance, modern Ingress Controllers look up the active EndpointSlice list and route the traffic directly to the Pod's private IP, completely bypassing the `ClusterIP` and avoiding an extra layer of kernel-level translation.

## Service Types: ClusterIP, NodePort, and LoadBalancer
Kubernetes Services are designed as a layered hierarchy. Each advanced Service type builds directly on top of the underlying layer, progressively expanding how far the application's network reach extends.

### ClusterIP
The default Kubernetes Service is ClusterIP. It provides a stable virtual IP address that is only routable from inside the Kubernetes cluster. It is impossible for external traffic to hit a ClusterIP directly.

When internal traffic hits this virtual IP, `kube-proxy` intercepts the packet and load-balances it across the healthy Pod IPs listed in the Service's EndpointSlice registry. For example, a backend API communicating with a database.

### NodePort
To allow traffic from outside the cluster to reach an internal application, Kubernetes uses the `NodePort` Service. A NodePort Service automatically creates a ClusterIP Service underneath it. 

When a `NodePort` Service is created, the Kubernetes control plane selects a port from a predefined range, then it instructs `kube-proxy` to open that exact port on the external IP address of every single worker Node in the cluster.

When an external client sends a request, the Node's kernel receives the traffic, forwards it to the underlying `ClusterIP`, then load-balances it to the correct Pod IP. It should be noted that relying only on NodePorts exposes non-standard ports to end-users and relies on specific Node IPs that could go down.

### LoadBalancer

The `LoadBalancer` Service is the standard method for exposing applications to the public internet in production environments. A LoadBalancer Service automatically creates a NodePort, which automatically creates a ClusterIP underneath the hood. It triggers the automatic provisioning of an external cloud load balancer that routes public traffic seamlessly into the cluster's NodePorts.