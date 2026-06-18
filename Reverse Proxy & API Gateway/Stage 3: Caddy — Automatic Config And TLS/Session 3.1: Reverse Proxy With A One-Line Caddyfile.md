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

    The traffic now between the client and the proxy was entirely encrypted over TLS (Transport Layer Security).

    **Plain HTTP Flow**:
   
       Client  ───(Plain Text)───►  Proxy  ───(Plain Text)───►  Backend

    **HTTPS / TLS Flow**:

        Client  ───(Encrypted)───►  Proxy  ───(Plain Text)───►  Backend
    
## Questions

1. **`curl -k https://...` to Caddy. Does the whoami output come back?**

    * ```
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
    When `curl -k https://localhost` to caddy, the request is encrypted to caddy, which then decrypts. Then, it forwards it internally over HTTP to `backend1`. It then receives the response, re-encrypts, and sends it back. So the `whoami` output appears exactly the same as it did before.

2. **Compare your Caddyfile length to your Nginx config. How many lines did the proxy take in each?**

    * **Nginx**: Around 10-12

    * **Caddy**: Just 4 lines in total.

3. **TLS terminates at Caddy. What are the security implications of the Caddy→backend hop being plain HTTP, and when would that matter?**

    * Because the traffic inside the `proxy-network` Docker network is **unencrypted**, any other container running on that same network that has been compromised _in theory_ could capture the traffic moving between Caddy and the backend. 

    * This matters when 
        
        * **`High-Security/Regulated Environments`**: In industries such as banking or healthcare that handles sensitive information. This needs encryption **everywhere** including inside the internal network as well. _(Zero Trust Security model)_

        * **`Shared/Multi-tenant Infrastructure`**: In case where you are running your containers on public cloud hosts where other might have access to the underlying network fabric, plain HTTP is a risk.

        * **`It does not matter for`**: Most internal microservices, where the risk is considered negligible becuase the Docker network is isolated. The complexity and the performance cost simply outweighs the benefits.