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

