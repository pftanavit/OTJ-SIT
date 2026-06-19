# Session 4.1: Route By Docker Labels

### Goal:

- Run `traefik` configured with the Docker provider. Add the `whoami` backend with Traefik **labels** so Traefik discovers it and routes to it by hostname — without you writing any route file.

### Constraints:

- Use the official `traefik` image.
- Traefik must read routes from the Docker provider (it needs access to the Docker socket).
- The route (host rule, port) is declared as **labels on the backend container**, not in a static config file.
- Enable the Traefik dashboard to observe discovered routes.

### Expected results:

- A request with the right `Host` header reaches the backend via Traefik.
- The Traefik dashboard shows the route that was discovered from the labels.

## Example

1. Launch `traefik-proxy` container and mount the host's `/var/run/docker.sock` file inside.

    ```
    docker run -d \
    --name traefik-proxy \
    --user 0:0 \
    -p 8080:80 \
    -p 8082:8080 \
    --network proxy-net \
    -v /var/run/docker.sock:/var/run/docker.sock \
    traefik:v3.6 \
    --api.insecure=true \
    --providers.docker=true \
    --providers.docker.exposedbydefault=false
    ```

    `--api.insecure=true` : enables the dashboard.

    `--providers.docker=true` : tells it to watch Docker.

    `-v /var/run/docker.sock` : allows traefik to watch Docker.

2. Create a `whoami` backend.

    ```
    docker run -d \
    --name dynamic-backend \
    --network proxy-net \
    --label "traefik.enable=true" \
    --label "traefik.http.routers.whoami-router.rule=Host(\`whoami.localhost\`)" \
    --label "traefik.http.services.whoami-service.loadbalancer.server.port=80" \
    traefik/whoami
    ```

    `traefik.enable=true` : expose the backend to traefik.

    `traefik.http.routers.whoami.rule=Host("whoami.localhost")` : tells Traefik to create a router named _whoami_ that catches any incoming traffic asking for _whoami.localhost_.

    `"traefik.http.services.whoami.loadbalancer.server.port=80"`: once Traefik catches the request, it sends it to _Services_, which then drops the request onto port 80 of the backend container.

3. Try running `curl`.
    ```
    curl -H "Host: whoami.localhost" http://localhost:8080
    ```
    Output:
    ```
    Hostname: 9c926d70184c
    IP: 127.0.0.1
    IP: ::1
    IP: 172.19.0.3
    RemoteAddr: 172.19.0.2:58504
    GET / HTTP/1.1
    Host: whoami.localhost
    User-Agent: curl/8.7.1
    Accept: */*
    Accept-Encoding: gzip
    X-Forwarded-For: 192.168.65.1
    X-Forwarded-Host: whoami.localhost
    X-Forwarded-Port: 80
    X-Forwarded-Proto: http
    X-Forwarded-Server: beca86b35318
    ```
4. Check the Traefik Dashboard.

    Go to http://localhost:8082

    Results:

    ![traefik-dashboard](https://github.com/user-attachments/assets/36d0d357-8ab2-4739-957b-331c487cf4b8)

    ![http-dashboard](https://github.com/user-attachments/assets/18149a27-bf9f-4aab-88a4-6a4f486575b3)

## Questions

1. **Open the Traefik dashboard. Is there a router pointing at your `whoami` service?**

    * Yes, whoami-router@docker points toward whoami service. It shows a successful link to whoami service proving that Traefik successfully reads the labels and mapped the internal IP. 

2. **`curl` with the correct `Host` header, then with a wrong one. Which succeeds, and what does the wrong one return?**

    * `curl -H "Host: whoami.localhost" http://localhost:8080`
    
        * ```
            Hostname: 9c926d70184c
            IP: 127.0.0.1
            IP: ::1
            IP: 172.19.0.3
            RemoteAddr: 172.19.0.2:50784
            GET / HTTP/1.1
            Host: whoami.localhost
            User-Agent: curl/8.7.1
            Accept: */*
            Accept-Encoding: gzip
            X-Forwarded-For: 192.168.65.1
            X-Forwarded-Host: whoami.localhost
            X-Forwarded-Port: 80
            X-Forwarded-Proto: http
            X-Forwarded-Server: beca86b35318
            ```

    * `curl -H "Host: wrong.domain" http://localhost:8080`: 

        * ```
            404 page not found
            ```

3. **Add a second labeled backend on a different host rule. Did you have to touch Traefik's config at all? Why is that powerful at scale?**

    * Launch the second backend container.

        * ```
            docker run -d \
            --name dynamic-backend-app2 \
            --network proxy-net \
            --label "traefik.enable=true" \
            --label 'traefik.http.routers.app2.rule=Host("app2.localhost")' \
            --label "traefik.http.services.app2.loadbalancer.server.port=80" \
            traefik/whoami
            ```
        * ```
            curl -H "Host: app2.localhost" http://localhost:8080
            ```
        * Output:
            ```
            Hostname: 573ee52b7f15
            IP: 127.0.0.1
            IP: ::1
            IP: 172.19.0.4
            RemoteAddr: 172.19.0.2:35722
            GET / HTTP/1.1
            Host: app2.localhost
            User-Agent: curl/8.7.1
            Accept: */*
            Accept-Encoding: gzip
            X-Forwarded-For: 192.168.65.1
            X-Forwarded-Host: app2.localhost
            X-Forwarded-Port: 80
            X-Forwarded-Proto: http
            X-Forwarded-Server: beca86b35318
            ```
    * No, Traefik's configurations remain untouched. There was no need to modify a single file or to relaunch a contain. At scale, this allows the infrastructure to run **seamlessly** and automatically without the need to manually changing the config every time a container changes its state.
4. **Why does Traefik need the Docker socket, and what is the risk of mounting it?**

    * The Docker socket is the core API of the Docker daemon. Traefik mounts this file so it can listen to live containers and read the internal IP of them. Without it, Traefik is blind.

    * Mounting the Docker socket is equivalent to giving the container root-level access to the host machine. If the Traefik container is compromised, it can be used to send commands to the host's Docker daemon, allowing it to take over the entire network system.