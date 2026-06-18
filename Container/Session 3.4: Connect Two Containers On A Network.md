# Session 3.4: Connect Two Containers On A Network

**Goal**:
* Create two Ubuntu-based containers on the same Docker network. One container runs a simple HTTP server. The other container uses curl to reach it by container name.

**Constraints**:

* Use only base OS images or images built from base OS images.
* Do not use host port publishing for container-to-container communication.
* Use a custom Docker network.

**Expected result**:
  
* One container can reach the other by name.

## Example

1. Create a brand new network.
    ```
    docker network create my-network
    ```
2. Create a new container on `my-network` using `custom-server` image built in *__Session 3.3__*
    ```
    docker run -d --name web-server --network my-network custom-server
    ```
3. Create another container that will be used to reach `web-server` container.
    ```
    docker run -it --rm --name test --network my-network ubuntu bash
    ```
4. Install `curl` inside the container.
    ```
    apt-get update && apt-get install -y curl
    ```
5. Use `curl` to reach the other container by name.
    ```
    curl http://web-server:8000
    ```
    Output:
    ```
    <h1>Hello from the custom Ubuntu HTTP server!</h1>
    ```

The `test` container is now able to reach `web-server` using `curl` running on the same Docker network.
