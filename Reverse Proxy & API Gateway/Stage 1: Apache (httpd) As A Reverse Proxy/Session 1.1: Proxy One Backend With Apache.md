# Session 1.1: Proxy One Backend With Apache

## Goal:

Run an `httpd` container that reverse-proxies incoming requests to the `whoami` backend. The client talks only to Apache; Apache forwards to the backend and returns the answer.

## Constraints:

- Use the official `httpd` image.
- The client must NOT publish or reach the backend's port directly — only Apache is published.
- Apache and the backend must be on the same Docker network so Apache can reach the backend by name.
- Enable the proxy modules and write the proxy config yourself.

## Expected result:

- `curl` to Apache's published port returns the whoami output.
- The whoami headers now show that the request came *through* Apache.

## Example

1. Create a new network `proxy-net`.

    ```
    docker network create proxy-net
    ```

2. Create a new backend container from `traefik/whoami` image.

    ```
    docker run -d --name my-backend --network proxy-net traefik/whoami
    ```

3. Write an Apache Config `my-http.conf`.

    ```
    Listen 80

    LoadModule proxy_module modules/mod_proxy.so
    LoadModule proxy_http_module modules/mod_proxy_http.so
    LoadModule mpm_event_module modules/mod_mpm_event.so
    LoadModule unixd_module modules/mod_unixd.so
    LoadModule authz_core_module modules/mod_authz_core.so

    <VirtualHost *:80>
        ProxyPass / http://my-backend/
        ProxyPassReverse / http://my-backend/
    </VirtualHost>
    ```

4. Create a container using `httpd` (Apache HTTP Server) image and mount `my-httpd.conf` inside the container.

    ```
    docker run -d --name my-proxy -p 8080:80 --network proxy-net -v "$(pwd)/my-httpd.conf:/usr/local/apache2/conf/httpd.conf" httpd
    ```

5. Try running `curl`.

    ```
    curl http://localhost:8080
    ```
    Output:
    ```
    Hostname: 2d5ac125bfca
    IP: 127.0.0.1
    IP: ::1
    IP: 172.19.0.2
    RemoteAddr: 172.19.0.3:60618
    GET / HTTP/1.1
    Host: my-backend
    User-Agent: curl/8.7.1
    Accept: */*
    Connection: Keep-Alive
    X-Forwarded-For: 192.168.65.1
    X-Forwarded-Host: localhost:8080
    X-Forwarded-Server: 172.19.0.3
    ```

## Questions

1. **`curl` Apache's port. In the whoami output, what is the `Hostname` — Apache's or the backend's?**

    * It is the backend's `Hostname`. `2d5ac125bfca` is the value of the `my-backend` container. The `whoami` application executes inside the the backend container and reads it `Hostname`.

2. **Look for `X-Forwarded-For` in the `whoami` headers. What IP is in it?**
    
    * The ip is from the original client. In this case, `192.168.65.1` is the internal virtual gateway IP used by Docker to represent the host machine.

3. **Try to `curl` the backend's port directly from the host. Does it work? Why not?**
    
    * Try:
        ```
        curl http://localhost:80
        ```
    * Output: 
        ```
        curl: (7) Failed to connect to localhost port 80 after 0 ms: Couldn't connect to server
        ```
        It does not work since the back end was never published. So, it is only accessible inside the `proxy-net` network.

4. **What does `ProxyPassReverse` fix that `ProxyPass` alone does not?**

    * It fixes `HTTP Redirects` sent by the backend so the client's browser does not get broken links. `ProxyPass` only handles incoming traffic. So, `ProxyPassReverse` changes `http://my-backend` to `http://localhost:8080`.
