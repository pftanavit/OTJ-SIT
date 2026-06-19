# Session 5.1: Route Through Kong

### Goal:

- Run `kong` in DB-less mode with a declarative config that defines a **Service** (the `whoami` backend) and a **Route** to it. Reach the backend through Kong.

### Constraints:

- Use the official `kong` image in DB-less / declarative mode (a `kong.yml` file, no Postgres).
- Define one Service and one Route.
- Only Kong is published; the backend stays internal.

### Expected result

- `curl` to Kong's proxy port, matching the route, returns the whoami output.


## Example

1. Create a new `whoami` backend container named `kong-backend`.

    ```
    docker run -d --name kong-backend --network proxy-net traefik/whoami
    ```

2. Create the Declarative Config.

    * Create a new file named `kong.yml` in the current directory.

    ```
    _format_version: "3.0"
    services:
    - name: whoami-service
        url: http://kong-backend:80
        routes:
        - name: whoami-route
            paths:
            - /api/whoami
            strip_path: true
    ```

    `url: http://kong-backend:80` : The Service. This defines the internal upstream target. 

    `paths: [/api/whoami]` : The route. This is the external entry point. It tells Kong what specific user requests should be allowed and linked to the service. 

    `strip_path: true` : The user requested `/api/whoami`, but the `whoami` backend did not account for `/api/whoami` folder path. This basically intercepted the request and cut off the prefix and left it with the root (`/`) folder path.
3. Launch Kong in DB-less mode.

    ```
    docker run -d --name kong-proxy \
    --network proxy-net \
    -e "KONG_DATABASE=off" \
    -e "KONG_DECLARATIVE_CONFIG=/opt/kong/kong.yml" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -v $(pwd)/kong.yml:/opt/kong/kong.yml \
    -p 8000:8000 \
    kong:latest
    ```

4. Try running `curl`.

    ```
    curl http://localhost:8000/api/whoami
    ```
    Output:
    ```
    Hostname: 4212a98543c9
    IP: 127.0.0.1
    IP: ::1
    IP: 172.19.0.2
    RemoteAddr: 172.19.0.3:40156
    GET / HTTP/1.1
    Host: kong-backend
    User-Agent: curl/8.7.1
    Accept: */*
    Connection: keep-alive
    Via: 1.1 kong/3.9.3
    X-Forwarded-For: 192.168.65.1
    X-Forwarded-Host: localhost
    X-Forwarded-Path: /api/whoami
    X-Forwarded-Port: 8000
    X-Forwarded-Prefix: /api/whoami
    X-Forwarded-Proto: http
    X-Kong-Request-Id: 77c8395cb2b65f1685c302088582d528
    ```

## Questions

1. **`curl` Kong on the route path. Does whoami answer?**

    * `curl http://localhost:8000/api/whoami` returns the network information.

2. **`curl` a path with no matching route. What status does Kong return?**

    Try:
    ```
    curl http://localhost:8000/dne
    ```
    Output:

        * ```
            {
            "message":"no Route matched with those values",
            "request_id":"e2239427f1bbfe7e4143de3211f0615f"
            }%
            ```
3. **What does DB-less mode trade away compared to running Kong with a database?**

    * **No Control Center GUI (Kong Manager)**: DB-less mode limits this because there is no database to store changes. So there is no dashboard to click around and add plugins, users, routes.

    * **No Real-Time Admin-API Updates**: In DB-less mode, the Admin API strictly becomes **read-only**. To update a route, you must manually rewrite the `kong.yml` file and trigger a configuration reload.

    * **Plugin Limitations**: some advanced Kong plugins relies on database to store their states and will not work in DB-less mode.

    * **Coordination at Mass Scale**: In DB-less mode, the automation tools have to manually push the updated `kong.yml` file to individual servers simultaneously.