# Kubernetes Controllers

In Kubernetes, controllers are control loops that watch the state of your cluster, then make or request changes where needed. Each controller tries to move the current cluster state closer to the desired state. A workload represents the actual application you are running, while a controller is the underlying background process that manages and maintains that workload's state

## ReplicaSet 

A `ReplicaSet` is a low-level workload designed to guarantee that a specific numbers of identical `Pods` are running at all times. It contains a ___label selector___ (to identify pods), a ___replica count___ (the desired number), and a ___Pod template___ (an image to use if it needs to build more).

The **ReplicaSet** endlessly counts the number of pods in the cluster that match its label selector. If the count is too low, it clones the Pod template to create new ones. If the count is too high, it terminates the excess Pods. It has mathematical tunnel vision. It does not care about application versions, rolling updates, or node topology, only the target pod count.

## Deployment 

A `Deployment` is a higher-level workload used to manage stateless applications (web servers, APIs, or microservices). It is similar to `ReplicaSet`, however, it adds an update strategy.

 `Deployment` manages `ReplicaSet` and watches Deployment YAML for any changes to the container image or configuration. When an app is updated, the controller creates a new `ReplicaSet` for the new code. It then acts as a dial, slowly turning up the replica count on the new `ReplicaSet` while turning down the count on the old one, ensuring a seamless transition.

## StatefulSet 

A StatefulSet is a workload designed for stateful applications, software that needs to save data, maintain a persistent identity, or be aware of its peers (databases, message queues, or cluster data stores). It includes everything a `Deployment` has, but adds a `volumeClaimTemplate`. This tells Kubernetes to dynamically provision a unique, persistent hard drive for every single pod. Typically used for running PostgreSQL, MongoDB, Kafka, or Elasticsearch.


The StatefulSet Controller is a **Sequential Identity Guardian**. This controller treats each Pod as a unique pet (`db-0`, `db-1`, `db-2`). It operates in strict, sequential order. It will not create `db-1` until `db-0` is fully running and healthy. If `db-1` crashes, the controller ensures that when the replacement boots up, it gets the exact same name (`db-1`) and reattaches to the exact same persistent storage volume it had before the crash.

## DaemonSet 

A DaemonSet is a workload designed to run a background agent on the infrastructure. It ensures that exactly one copy of a specific Pod runs on every single worker Node in the cluster (or a specific subset of nodes based on labels). Typically used for running cluster-wide background tasks like log collectors (Fluentd), monitoring agents (Prometheus Node Exporter), or networking plugins (Calico). It is similar to `ReplicaSet`, however, the replicas count is determine entirely by how many nodes or machines is in the cluster.

The DaemonSet Controller is an **Infrastructure Map Maker**. It constantly monitors the cluster's list of available worker Nodes. If your cloud provider automatically adds a new Node to handle a spike in web traffic, the DaemonSet controller spots the new Node and instantly deploys its Pod onto it. If a Node is permanently deleted, the controller cleans up the orphaned Pod.