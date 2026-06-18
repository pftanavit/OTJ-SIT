# Session 3.4: Connect Two Containers On A Network

### Goal:
* Create two Ubuntu-based containers on the same Docker network. One container runs a simple HTTP server. The other container uses curl to reach it by container name.

### Constraints:

* Use only base OS images or images built from base OS images.
* Do not use host port publishing for container-to-container communication.
* Use a custom Docker network.

### Expected result:
  
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

## Questions 

1. **Why did container name resolution work?**

    * Because both the containers are on the same network `my-network` that was created. Docker automatically registers the container names in its built-in DNS server.

2. **Why did localhost not reach the other container?**

    * Since containers have isolated network boundaries, `localhost` would mean its own web server. It would be finding its own process web server that does not exist instead.

3. **When do you need -p, and when do you not?**

    * `-p (publish)` would be needed when using container to host. It connects your host machine to the isolated  Docker environment.

    * For container to container, `-p` is not necessary. If both containers are on the same custom network, they can communicate and reach each other.

4. **From the client container, run getent hosts `<other-name>`. What IP address comes back?**
    
    * Output:
      ```
      172.18.0.2      web-server
      ```
    * This returns the internal IP Address Docker assigned to that container.

5. **Run ip addr in both containers. Do they have different IP addresses?**

    * Yes, they are different. In `test`, it shows `172.18.0.3`. In `web-server`, 172.18.0.2. Every single container on a Docker network gets its own distinct internal IP Address. Docker acts as a virtual DHCP router handind out IPs.

6. **How did the container name turn into an IP address?**

    * Docker uses Embeded DNS Server `127.0.0.11`. This helps `curl` locate `web-server` by matching the IP of it to `127.18.0.2` and hands it back to `curl`. It is then able to make that connection. 
