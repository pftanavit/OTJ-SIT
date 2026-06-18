## Session 3.1: Reverse Proxy With A One-Line Caddyfile

### Goal:

- Use a `caddy` container to reverse-proxy to the `whoami` backend with a minimal Caddyfile, and serve it over HTTPS using Caddy's local/internal certificate.

### Constraints:

- Use the official `caddy` image.
- The reverse-proxy directive should be a single line in the Caddyfile.
- Enable TLS using Caddy's internal/local CA (no public domain needed for the lab).

### Expected results:

- `curl` (with the internal CA trusted, or `-k` for the lab) over HTTPS returns the whoami output.
- The learner can show the one-line `reverse_proxy` directive.

## Example

1. Create a minimal Caddyfile.
    
    Create a new file name `Caddyfile` in your current directory.

    ```
    localhost {
    tls internal
    reverse_proxy backend1:80
    }
    ```

2. Launch the Caddy Proxy.

    ```
    docker run -d --name caddy-proxy -p 443:443 --network proxy-net -v "$(pwd)/Caddyfile:/etc/caddy/Codyfile" caddy
    ```

    Port `443` is the standard port for `HTTPS`

3. Try running `curl`.

    ```
    curl -k https://localhost
    ```
    Output: 
    ```
    Hostname: 856e6681f4b5
    IP: 127.0.0.1
    IP: ::1
    IP: 172.19.0.2
    RemoteAddr: 172.19.0.3:35196
    GET / HTTP/1.1
    Host: localhost
    User-Agent: curl/8.7.1
    Accept: */*
    Accept-Encoding: gzip
    Via: 2.0 Caddy
    X-Forwarded-For: 172.19.0.1
    X-Forwarded-Host: localhost
    X-Forwarded-Proto: https
    ```

    Caddy serve this over HTTPS using its `internal`. The proxy is likely using a self-signed certificate that generated on this machine. So, using`curl -k` or (`--insecure`) bypasses a website or proxy that uses a **Self-Signed SSL Certificate** or an **untrusted/expired certificate**. 