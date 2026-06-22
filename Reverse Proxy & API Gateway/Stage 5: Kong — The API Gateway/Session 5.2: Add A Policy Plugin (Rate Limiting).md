# Session 5.2: Add A Policy Plugin (Rate Limiting)

### Goal:

- Add the `rate-limiting` plugin to the route so that after N requests per minute, Kong rejects further requests — before they ever reach the backend.

### Constraints:

- Add the plugin declaratively to the existing route.
- Pick a small limit so it is easy to trip.

### Expected result:

- The first N requests succeed; the next is rejected by Kong with a 429, and the backend never sees it.

## Example

1. Update `kong.yml` to include _rate-limiting_.

    ```
    cat << 'EOF' > kong.yml
    _format_version: "3.0"
    services:
    - name: whoami-service
        url: http://kong-backend:80
        routes:
        - name: whoami-route
            paths:
            - /api/whoami
            strip_path: true
            plugins:
            - name: rate-limiting
                config:
                minute: 3
                policy: local
    ```
2. Restart `kong-proxy`.

    ```
    docker restart kong-proxy
    ```
3. Test the `rate-limiter` by running `curl` 4 times.

    ```
    curl -i http://localhost:8000/api/whoami
    ```

    Output:
    ```
    Hostname: 4212a98543c9
    IP: 127.0.0.1
    IP: ::1
    IP: 172.19.0.3
    RemoteAddr: 172.19.0.2:47860
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
    X-Kong-Request-Id: aeae5b75eed3f915a14ae36ca595a30d
    ```
    ```
    {
    "message":"API rate limit exceeded",
    "request_id":"b9dfce7b943e764e21c6a766210edd49"
    }%
    ```
    _On the fourth request, it fails and reject with the message "API rate limit exceeded._

## Questions

1. **Hammer the route past the limit. At which request number does the status change to 429?**

    * On request number 4, the HTTP status changes to `429 Too Many Request`. This is because of the configurations of `minute: 3` that only allows 3 requests in that 60 second window. Once it reaches that count, the next request is out of budget and it instantly rejects the connection.

2. **Check the backend's logs. Did the rejected requests reach it?**

    * No, it does not reach the backend. The first three requests are normal. However, on the fourth request, it hit an error code `429 Too Many Request` and reject its connection to the backend.

3. **Rate limiting and authentication both run at the gateway. Why is enforcing them here better than in every backend service?**

    * `Don't Repeat Yourself`: This principle applies, since if there are many microservices, you would have to write it and tailor it to each specific one. By enforcing it here, you only have to do it once and it applies everywhere.

    * `Resource and Cost Protection`: Code excution cost money. This can prevent any malicious attacks or DDOS. It protects the precious computing resource of the backend.

    * `Uniform Security Standards`: Having a centralized security standards ensures that all incoming traffic passes through the same screening. This also eliminates any chance of human error in each specific code.

    * `Time and Resource`: With gateway and security sorted, other developers can then spend more time on developing and building their code without having to worry or focus on the traffic and safety.
