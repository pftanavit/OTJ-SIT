## Session 2.1: Proxy One Backend With Nginx

### Goal:

Replace Apache with an `nginx` container doing the same reverse-proxy job to the single `whoami` backend.

### Constraints:

- Use the official `nginx` image.
- Only Nginx is published; the backend stays internal.
- Write the `proxy_pass` config yourself.

### Expected results:

- `curl` to Nginx returns the whoami output, same as the Apache stage.

## Example

Similar to __*Stage 1.1 Proxy One Backend With Apache*__, however, this time we use **nginx** insted.

1. Write an Nginx Config `my-nginx.conf`.
    ```
    events {}

    http {
        server {
            listen 80;

            location / {
                proxy_pass http://my-backend;
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }
        }
    }
    ```
2. Create a container from `nginx` image to `proxy-net` network and mount `my-nginx.conf` inside the container.

    ```
    docker run -d -p 8080:80 --name nginx-proxy --network proxy-net -v "$(pwd)/my-nginx.conf:/etc/nginx/nginx.conf" nginx
    ```
3. Try running `curl`.
    ```
    curl http://localhost:8080
    ```
    Output:
    ```
    Hostname: 2d5ac125bfca
    IP: 127.0.0.1
    IP: ::1
    IP: 172.19.0.2
    RemoteAddr: 172.19.0.3:43858
    GET / HTTP/1.1
    Host: localhost
    User-Agent: curl/8.7.1
    Accept: */*
    X-Forwarded-For: 172.19.0.1
    ```

## Questions

1. **`curl` Nginx. Is the whoami `Hostname` the backend's, as expected?**

    * Yes, the `Hostname` is the backend's as expected. Proxy just forwards the HTTP Traffic, it still executes the process inside that container.

2. **Which `proxy_set_header` line controls what the backend sees as the `Host`?**

    * `proxy_set_header Host $host;`
        This prevents Nginx from overwriting the destination with its own internal names and provide with what the user asked for.

3. **Nginx and Apache did the same thing here. What would make you pick one over the other?**

    * `Apache HTTP`: Apache is process driven. Spawns new thread for each connection. Can consume more RAM under heavy traffic. Support `.htaccess` files.

    * `Nginx`: Evet driven, handles thousands of concurrent connection within a single process. Extremely lightweight. Does not support `.htaccess`. Uses C-like block structure.

    * For simple use, either is perfectly fine. But for modern microservices and heavy reverse-proxying, **Nginx** is often the industry standard.
