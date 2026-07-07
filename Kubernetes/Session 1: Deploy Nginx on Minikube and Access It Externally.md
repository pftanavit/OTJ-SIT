# Session 1: Deploy Nginx on Minikube (via Docker Desktop) and Access It Externally

### Goal:
* Start Minikube inside Docker Desktop, deploy an Nginx pod, expose it as a Service, and access the running Nginx page from your host machine's browser or terminal.

### Constraints:

* Use only the nginx image (no custom Dockerfile).
* Use kubectl to create the pod and service — no YAML manifests yet (imperative commands only).
* Do not modify Nginx's default config or content.
Show every command you used, in order.

### Expected result:

* Minikube cluster is running inside Docker Desktop.
* Can create a pod running Nginx and confirm it's in Running state.
* Can expose the pod via a Service.
* Can reach Nginx's default welcome page from outside the cluster (host browser/curl), not just from inside the pod.

## Example

Install both `minikube` and `kubectl` and ensure that Docker Desktop is open and runnning on your machine.

```
brew install minikube kubectl
```

1. Start the minikube cluster and tell it to use Docker as the driver.

    ```
    minikube start --driver=docker
    ```

2. Deploy a new Nginx Pod.

    ```
    kubectl run nginx --image=nginx --port=80
    ```

3. Verify that the Pod is running.

    ```
    kubectl get pods
    ```
    Output:

    ```
    NAME    READY   STATUS    RESTARTS   AGE
    nginx   1/1     Running   0          19s
    ```
4. Expose the Pod as a Service using `NodePort`.
    ```
    kubectl expose pod nginx --type=NodePort --port=80
    ```
5. Verify the Service.
    ```
    kubectl get services
    ```
    Output:
    ```
    NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
    kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        16m
    nginx        NodePort    10.111.147.164   <none>        80:31830/TCP   12m
    ```
    _The kuberbetes is the default Service that automatically creates in every cluster, in the default namespace. It exposes the Kubernetes API server itself to pods running inside the cluster. This basically allows pods to reach the API server internally at a fixed address._

6. Access Nginx from Host.

    ```
    minikube service nginx
    ```
    _Because Minikube is running inside a Docker container, the Node's IP address isn't directly reachable from your host machine's browser by default. This command automatically configures a local proxy network and launches your default web browser to display your running application._

    Output:
    ![nginx-web](https://github.com/user-attachments/assets/485fb5d4-80f0-4218-b739-cea8b69a1f19)

7. Try `curl`:

    ```
    minikube service nginx --url
    ```
    Output:
    ```
    http://127.0.0.1:56977
    ```
    Now `curl`
    ```
    curl http://127.0.0.1:56977
    ```
    Output:
    ```
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
    html { color-scheme: light dark; }
    body { width: 35em; margin: 0 auto;
    font-family: Tahoma, Verdana, Arial, sans-serif; }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, nginx is successfully installed and working.
    Further configuration is required for the web server, reverse proxy, 
    API gateway, load balancer, content cache, or other features.</p>

    <p>For online documentation and support please refer to
    <a href="https://nginx.org/">nginx.org</a>.<br/>
    To engage with the community please visit
    <a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
    For enterprise grade support, professional services, additional 
    security features and capabilities please refer to
    <a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>
    ```