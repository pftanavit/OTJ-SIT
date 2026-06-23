# Session 6.1: Build The Stack

### Goal:

- Write one `compose.yml` that brings up Traefik, Kong (DB-less), the web backends, and the api backend, with one command, so that `/` reaches the web pool and `/api` goes through Kong.

### Constraints:

- One `docker compose up` brings up everything.
- Traefik routes by path; the web path is load-balanced across at least two backends.
- The `/api` path passes through Kong and is rate-limited before reaching the api backend.
- No backend is published directly — Traefik is the only public entrypoint.
- The learner writes the whole `compose.yml` and Kong declarative config from scratch.

### Expected results:

- `docker compose up` starts the whole stack.
- A request to `/` returns a web backend, cycling across the pool.
- A request to `/api` returns the api backend — until the rate limit trips, then 429.

## Example

1. Build the new stack.

    * Create a new docker compose file `compose.yml` that includes everything.
        ```
        version: "3.8"

        networks:
        edge-net:
            name: edge-net
            driver: bridge
        api-net:
            name: api-net
            driver: bridge

        services:

        traefik:
            image: traefik:v3.6
            command:
            - "--api.insecure=true"
            - "--providers.docker=true"
            - "--entrypoints.web.address=:80"
            ports:
            - "80:80"
            - "8080:8080"
            networks:
            - edge-net
            volumes:
            - "/var/run/docker.sock.raw:/var/run/docker.sock:ro"

        web-backend:
            image: traefik/whoami
            networks:
            - edge-net
            deploy:
            replicas: 2
            labels:
            - "traefik.enable=true"
            - "traefik.http.routers.web-pool.rule=PathPrefix(`/`)"
            - "traefik.http.routers.web-pool.entrypoints=web"

        kong-proxy:
            image: kong:3.4
            container_name: kong-proxy
            environment:
            KONG_DATABASE: "off"
            KONG_DECLARATIVE_CONFIG: /usr/local/kong/declarative/kong.yml
            KONG_PROXY_LISTEN: 0.0.0.0:8000
            labels:
            - "traefik.enable=true"
            - "traefik.http.routers.kong-router.rule=PathPrefix(`/api`)"
            - "traefik.http.routers.kong-router.service=kong-service"
            - "traefik.http.services.kong-service.loadbalancer.server.port=8000"
            - "traefik.docker.network=edge-net"
            networks:
            - edge-net
            - api-net
            volumes:
            - ./kong.yml:/usr/local/kong/declarative/kong.yml
            
        api-backend:
            image: traefik/whoami
            networks:
            - api-net
        ```
2. Update `kong.yml`. 

    ```
    _format_version: "3.0"
    services:
    - name: hidden-api-service
        url: http://api-backend:80
        routes:
        - name: api-route
            paths:
            - /api
            strip_path: true
            plugins:
            - name: rate-limiting
                config:
                minute: 3
                policy: local
    ```

3. Bring the stack up.

    ```
    docker compose up
    ```

    Output:
    ![output-docker-compose](https://github.com/user-attachments/assets/bb277a22-2e5c-412c-ba01-eb23edc93fa2)
    
4. Try running `curl`.

    * `curl http://localhost`

        Output:
        ```
        Hostname: 3acd6c0a3736
        IP: 127.0.0.1
        IP: ::1
        IP: 172.20.0.2
        RemoteAddr: 172.20.0.3:41526
        GET / HTTP/1.1
        Host: localhost
        User-Agent: curl/8.7.1
        Accept: */*
        Accept-Encoding: gzip
        X-Forwarded-For: 192.168.65.1
        X-Forwarded-Host: localhost
        X-Forwarded-Port: 80
        X-Forwarded-Proto: http
        X-Forwarded-Server: 85e4e340aebf
        ```
        ```
        Hostname: d25a1f7114cd
        IP: 127.0.0.1
        IP: ::1
        IP: 172.20.0.5
        RemoteAddr: 172.20.0.3:47066
        GET / HTTP/1.1
        Host: localhost
        User-Agent: curl/8.7.1
        Accept: */*
        Accept-Encoding: gzip
        X-Forwarded-For: 192.168.65.1
        X-Forwarded-Host: localhost
        X-Forwarded-Port: 80
        X-Forwarded-Proto: http
        X-Forwarded-Server: 85e4e340aebf
        ```
        _Notice that the hostname changes as `Traefik` balances the traffic request to `web-backend` containers._
    
    * `curl -i http://localhost/api`

        Output:
        ```
        HTTP/1.1 200 OK
        Content-Length: 438
        Content-Type: text/plain; charset=utf-8
        Date: Tue, 23 Jun 2026 03:52:17 GMT
        Ratelimit-Limit: 3
        Ratelimit-Remaining: 2
        Ratelimit-Reset: 43
        Via: kong/3.4.2
        X-Kong-Proxy-Latency: 237
        X-Kong-Upstream-Latency: 2
        X-Ratelimit-Limit-Minute: 3
        X-Ratelimit-Remaining-Minute: 2

        Hostname: e07713516200
        IP: 127.0.0.1
        IP: ::1
        IP: 172.23.0.2
        RemoteAddr: 172.23.0.3:50196
        GET / HTTP/1.1
        Host: api-backend
        User-Agent: curl/8.7.1
        Accept: */*
        Accept-Encoding: gzip
        Connection: keep-alive
        X-Forwarded-For: 192.168.65.1, 172.22.0.3
        X-Forwarded-Host: localhost
        X-Forwarded-Path: /api
        X-Forwarded-Port: 8000
        X-Forwarded-Prefix: /api
        X-Forwarded-Proto: http
        X-Forwarded-Server: d77fd58383b3
        ```
        ```
        HTTP/1.1 429 Too Many Requests
        Content-Length: 41
        Content-Type: application/json; charset=utf-8
        Date: Tue, 23 Jun 2026 03:52:31 GMT
        Ratelimit-Limit: 3
        Ratelimit-Remaining: 0
        Ratelimit-Reset: 29
        Retry-After: 29
        Server: kong/3.4.2
        X-Kong-Response-Latency: 1
        X-Ratelimit-Limit-Minute: 3
        X-Ratelimit-Remaining-Minute: 0

        {
        "message":"API rate limit exceeded"
        }%                                       
        ```
        _After 3 requests, `curl` returns `Error 429 Too Many Requests`. This happens because we configured kong to 3 requests per minute limit._

## Explaination

* **`compose.yml`** : 

    * 
        ```
        version: "3.8"

        networks:
        edge-net:
            name: edge-net
            driver: bridge
        api-net:
            name: api-net
            driver: bridge
        ```
        * `version: "3.8"` : Tells Docker Compose which feature set and syntax to expect.
        * `networks:` : Creates custom, isolated virtual networks. 
        * `name:` : Forces Docker to use these names for the network instead of its default, adding folder name in front, which can confuse `Traefik`.
        * `driver: bridge` : The standard network type for containers on a single machine to talk to each other.

    * 
        ```
        traefik:
        image: traefik:v3.6
        command:
          - "--api.insecure=true"
          - "--providers.docker=true"
          - "--entrypoints.web.address=:80"
        ports:
          - "80:80"
          - "8080:8080"
        networks:
          - edge-net
        volumes:
          - "/var/run/docker.sock.raw:/var/run/docker.sock:ro"
        ```
        * `traefik:` : Defines the edge router service that acts as the public-facing front door for your infrastructure.
        * `image: traefik:v3.6` : Specifies the Traefik version.
        * `command:` : Passes startup arguments directly to the Traefik container.
        * `--api.insecure=true` : Enables the Traefik web dashboard for monitoring.
        * `--providers.docker=true` : Tells Traefik to continuously listen to the Docker socket to automatically discover new containers and routing labels.
        * `--entrypoints.web.address=:80` : Defines an entry point named `web` that listens for incoming HTTP traffic on port 80.
        * `ports:` : Maps host machine ports to container ports (Port 80 for web traffic, Port 8080 for the dashboard).
        * `networks:` : Connects Traefik *only* to the public-facing `edge-net`.
        * `volumes:` : Mounts the host's Docker socket into the container as read-only (`:ro`) so Traefik can "see" other containers. Using `.raw` bypasses Mac/Windows Docker Desktop symlink issues.

    * 
        ```
        web-backend:
        image: traefik/whoami
        networks:
          - edge-net
        deploy:
          replicas: 2
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.web-pool.rule=PathPrefix(`/`)"
          - "traefik.http.routers.web-pool.entrypoints=web"
        ```
        * `web-backend:` : Represents your standard public website pool.
        * `image: traefik/whoami` : A tiny HTTP server that prints OS information and its internal IP, perfect for testing load balancing.
        * `networks:` : Connects this service to the public-facing `edge-net`.
        * `deploy: replicas: 2` : Tells Docker to spin up two identical copies of this container for Traefik to load balance automatically.
        * `labels:` : Metadata instructions that Traefik reads dynamically to build routing rules.
        * `traefik.enable=true` : Explicitly tells Traefik to route traffic to this specific container.
        * `...rule=PathPrefix('/')` : A catch-all rule that routes any general traffic hitting the root path to this web pool.
        * `...entrypoints=web` : Instructs Traefik to listen for these requests on the port 80 `web` entrypoint defined earlier.
    
    * 
        ```
        kong-proxy:
        image: kong:3.4
        container_name: kong-proxy
        environment:
          KONG_DATABASE: "off"
          KONG_DECLARATIVE_CONFIG: /usr/local/kong/declarative/kong.yml
          KONG_PROXY_LISTEN: 0.0.0.0:8000
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.kong-router.rule=PathPrefix(`/api`)"
          - "traefik.http.routers.kong-router.service=kong-service"
          - "traefik.http.services.kong-service.loadbalancer.server.port=8000"
          - "traefik.docker.network=edge-net"
        networks:
          - edge-net
          - api-net
        volumes:
          - ./kong.yml:/usr/local/kong/declarative/kong.yml
        ```
        * `kong-proxy:` : The API Gateway acting as a secure middleman and policy enforcer for backend APIs.
        * `environment:` : Sets environmental variables to configure Kong on startup.
        * `KONG_DATABASE: "off"` : Runs Kong in "DB-less" mode, reading configuration from a file instead of a database.
        * `KONG_DECLARATIVE_CONFIG:` : Points Kong to the internal file path where it should read its routing rules.
        * `KONG_PROXY_LISTEN:` : Tells Kong to listen for incoming proxy traffic on internal port 8000.
        * `...rule=PathPrefix('/api')` : Traefik intercepts any URL starting with `/api` and forwards it to Kong.
        * `...router.service=kong-service` : Bridges Traefik's routing logic to a specific custom service.
        * `...server.port=8000` : Explicitly tells Traefik to send traffic to Kong's port 8000 (preventing port confusion and 504 timeouts).
        * `traefik.docker.network=edge-net` : Forces Traefik to use Kong's `edge-net` IP address for communication.
        * `networks:` : Connects Kong to *both* `edge-net` and `api-net`, making it the literal bridge between the public edge and private backend.
        * `volumes:` : Mounts your local `kong.yml` file into the container for Kong to read its DB-less configuration.

    * 
        ```
        api-backend:
        image: traefik/whoami
        networks:
          - api-net
        ```
        * `api-backend:` : Represents your sensitive internal servers, databases, or microservices.
        * `image: traefik/whoami` : The test application serving as the protected backend.
        * `networks:` : Connects this service *only* to the `api-net`. Because it lacks an `edge-net` connection, Traefik and the outside world cannot reach it; traffic must pass through Kong's gateway rules first.

* **`kong.yml`** : 
    
    * 
        ```
        _format_version: "3.0"
        ```
        * `_format_version: "3.0"` : Specifies the declarative syntax and schema version that Kong uses to parse this file. Version 3.0 is required for Kong 3.x+.
    
    * 
        ```
        services:
        - name: hidden-api-service
          url: http://api-backend:80
        ```
        * `services:` : Defines the upstream APIs or backend microservices that Kong will forward traffic to.
        * `name: hidden-api-service` : An internal nickname given to this upstream service within Kong for logging and identification.
        * `url: http://api-backend:80` : The actual network location of the destination server. It points to the `api-backend` container name on internal port 80 over the isolated `api-net` network.
    
    * 
        ```
        routes:
          - name: api-route
            paths:
              - /api
            strip_path: true
        ```
        * `routes:` : Defines the entry rules that map incoming public requests to this specific backend service.
        * `name: api-route` : An internal nickname for this specific path matching rule.
        * `paths: [ /api ]` : Tells Kong to intercept any incoming traffic targeting the `/api` endpoint.
        * `strip_path: true` : A crucial cleanup rule. It cuts the `/api` prefix off the URL before sending it to the backend. For example, a request to `localhost/api/users` is rewritten to just `api-backend:80/users` so the backend server doesn't get confused by the gateway's prefix.

    * 
        ```
        plugins:
              - name: rate-limiting
                config:
                  minute: 3
                  policy: local
        ```
        * `plugins:` : Attaches middleware or policy enforcers directly to this specific route.
        * `name: rate-limiting` : Activates Kong's core rate-limiting traffic control plugin.
        * `config:` : Pass parameters to customize how the plugin operates.
        * `minute: 3` : Sets the strict threshold constraint. Any single IP address is allowed a maximum of 3 requests per minute.
        * `policy: local` : Tells Kong to track and store the request counters in-memory inside the container locally, rather than connecting to an external cluster database like Redis.

## Questions

1. **`curl /` several times. Do you see the web backends cycling?**

    * Yes, this is due to the default round robin balancing of Traefik. This alternating pattern perfectly distributes traffic across the backend replicas.

2. **`curl /api` past the limit. Where does the 429 come from — Traefik or Kong?**

    * From Kong, Traefik handles the initial request. When it sees `/api`, it then forwards it to Kong to handle th process.

3. **Check each service's logs. Trace one `/api` request across the log lines of Traefik, Kong, and the backend.**

    * The `/api` request goes from the machine to `Traefik` then `Kong` and lastly `api-backend`.

4. **If you removed Kong and pointed `/api` straight at the backend, what protection would you lose?**

    * You would lose `rate-limiting` and would directly expose the `api-backend` to `edge-net`.

5. **Add a new backend with the right labels while the stack is running. Does Traefik route to it without a restart? Why?**
    
    * `Traefik` instantly updates its routing pool and begins spreading the incoming requests across all 5 containers seamlessly. This is due to **zero-downtime scaling**.