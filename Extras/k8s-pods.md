# Kubernetes Pods

A pod is a co-located group of containers and the basic building block in Kubernetes. It can help deploy and manage a group of containers as a single unit. When a pod has multiple containers, all of them run on the same worker node. 

When containers share a pod, they share:

- **A Single IP Address**: They all share the same network namespace and can talk to each other via `localhost`.
- **Shared Storage**: You can attach a volume to a pod and all the containers inside that pod would be able to read and write to it.

### Creating a Pod

1. Create a pod manifest file. `simple-pod.yaml`

    ```
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80

    ```
2. Create the Pod object from the YAML file.
    
    ```
    kubectl apply -f simple-pod.yaml
    ```

Usually, pods are not created directly. Instead, they are managed through _**workload resources**._

## Workloads

A workload is an application running on Kubernetes and it runs inside of Pods. Kubernetes provides several built-in workload resources that help manage sets of pods.

- **`Deployment`** and **`ReplicaSet`**: A Deployment manages a set of Pods to run an application workload, usually one that doesn't maintain state. A `ReplicaSet`'s purpose is to maintain a stable set of replica Pods running at any given time. Usually, you define a `Deployment` and let that `Deployment` manage `ReplicaSets` automatically.


- **`StatefulSet`**: A StatefulSet runs a group of Pods, and maintains a sticky identity for each of those Pods. It is useful for managing applications that need persistent storage or a stable, unique network identity.

- **`DaemonSet`**: A DaemonSet defines Pods that provide node-local facilities. These might be fundamental to the operation of your cluster, such as a networking helper tool, or be part of an add-on.

- **`Job`** and **`CronJob`**: provide different ways to define tasks that run to completion and then stop. You can use a `Job` to define a task that runs to completion, just once. `CronJob` can be used to run the same Job multiple times according to a schedule.

## Pod Lifecycle

Pods follow a defined lifecycle. Like individual application containers, Pods are considered to be relatively **ephemeral** entities. Pods are created, assigned a unique ID (UID), and scheduled to run on nodes where they remain until termination or deletion. If a Node dies, the Pods running on (or scheduled to run on) that node are marked for deletion. The control plane marks the Pods for removal after a timeout period.

### Pod Phase

The phase of a Pod is a simple, high-level summary of where the Pod is in its lifecycle.


|Pod Phase|Description|
| :---: | :--- |
|`Pending`|After you create the Pod object, this is its initial phase. Until the pod is scheduled to a node and the images of its container are pulled and started, it remains in this phase.|
|`Running`|The Pod has been bound to a node, and all of the containers have been created. At least one container is still running, or is in the process of starting or restarting.|
|`Succeeded`|Pods that are not intended to run indefinitely are marked as `Succeeded` when all their containers complete successfully.|
|`Failed`|When a pod is not configured to run indefinitely and at least one of its containers terminates unsuccessfully, the pod is marked as `Failed`.|
|`Unknown`|For some reason the state of the Pod could not be obtained. This phase typically occurs due to an error in communicating with the node where the Pod should be running|

### Pod Conditions

Pod phase gives a summary of where it is in its lifecycle. To learn more about the condition of the pod, you can look at the list of conditions. A pod's conditions indicate whether a pod has reached a certain state or not, and why that is the case.


|Pod Condition|Description|
| :---: | :--- |
|`PodScheduled`|Indicates whether or not the pod has been scheduled to a node.|
|`Initialized`|The pod's init containers have all completed successfully.|
|`ContainersReady`|All containers in the pod indicate that they are ready. This is a necessary but not sufficient condition for the entire pod to be ready.|
|`Ready`|The pod is ready to provide services to its clients. The containers in the pod and the pod's readiness gates are all reporting that they are ready.|

### Container States

As well as the phase of the Pod overall, Kubernetes tracks the state of each container inside a Pod. You can use container lifecycle hooks to trigger events to run at certain points in a container's lifecycle. A container can be in one of the three states below.


|Container State|Description|
| :---: | :--- |
|`Waiting`|The container is waiting to be started. The `reason` and `message` fields indicate why the container is in this state.|
|`Running`|The container has been created and processes are running in it. The `startedAt` field indicates the time at which this container was started.|
|`Terminated`|The processes that had been running in the container have terminated. The `startedAt` and `finishedAt` fields indicate when the container was started and when it terminated. The exit code with which the main process terminated is in the `exitCode` field.|

### Container restarts

When a container in your Pod stops or experiences failure, the `kubelet` can restart it. A restart isn't always appropriate; for example, standard init containers run only once (if successful) during Pod startup. You configure this behavior using a restart policy that applies to all regular containers within the Pod.

### Pod-level container restart policy

By default, Kubernetes restarts the container regardless of whether the process in the container exits with a zero or non-zero exit code. This behavior can be changed by setting the `restartPolicy` field in the pod's spec.

- **`Always`**: Automatically restarts the container after any termination.

- **`OnFailure`**: Only restarts the container if it exits with an error (non-zero exit status).

- **`Never`**: Does not automatically restart the terminated container.

### Restart Behavior Comparison


|Exit Code|`Always`|`OnFailure`|`Never`|
| :---: | :---: | :---: | :---: |
|0 (Success)|Restarts|Does not restart|Does not restart|
|Non-zero (Failure)|Restarts|Restarts|Does not restart|

## Liveness, Readiness, and Startup Probes

Kubernetes lets you define probes to continuously monitor the health of containers in a Pod. A probe is a diagnostic performed periodically by the kubelet on a container. To perform a diagnostic, the kubelet either executes code within the container or makes a network request.

### Startup probe

Startup probes verify whether the application within a container is started. If a startup probe is configured, Kubernetes does not execute liveness or readiness probes until the startup probe succeeds, allowing the application time to finish its initialization.

### Liveness probe

Liveness probes determine when to restart a container. For example, liveness probes could catch a deadlock, where an application is running, but unable to make progress. Restarting a container in such a state can help to make the application more available despite bugs.

If a container fails its liveness probe more times than the configured tolerance, the kubelet restarts that container. Liveness probes do not wait for readiness probes to succeed. If you want to wait before executing a liveness probe, you can either define initialDelaySeconds or use a startup probe.

### Readiness probe

Readiness probes determine when a container is ready to accept traffic. This is useful when waiting for an application to perform time-consuming initial tasks, such as establishing network connections, loading files, and warming caches. Readiness probes can also be useful later in the container’s lifecycle, for example, when recovering from temporary faults or overloads.

## Init Containers

A Pod can have multiple containers running apps within it, but it can also have one or more init containers, which are run before the app containers are started. Init containers are just like regular containers, however, they do not run in parallel - only one init container runs at a time.

### Common uses of init containers:

Init containers are typically added to pods to:

- Initialize files in the volumes used by the pod's main containers. Because init containers run to completion before the main containers start, they are perfect for staging data. For example, an init container could clone a Git repository into a shared volume, dynamically generate a configuration file from a template, or extract a heavy ZIP archive so the data is ready to go the second your main web server container boots up.

- Initialize the pod's networking system. Main application containers should generally run with the least privilege possible. If your pod requires advanced network routing or custom `iptables` rules, you can run a highly privileged init container to execute these network changes and then exit. The main container can then run securely without needing root or elevated network capabilities.

- Delay the start of the pod's main containers until a precondition is met. If your web application relies on a database, it will likely crash if it starts before the database is ready. You can use an init container that continuously pings or runs `nslookup` on the database service, only exiting successfully when the database answers. This prevents your main container from getting stuck in a frustrating `CrashLoopBackOff` cycle.

- Notify an external service that the pod is about to start running. Sometimes, external infrastructure needs to know a pod is coming online before it starts accepting traffic. An init container can be used to send an HTTP POST request or webhook to register the pod with an external service registry, a custom load balancer, or a monitoring dashboard, ensuring the external system is prepared before the main application starts processing data.