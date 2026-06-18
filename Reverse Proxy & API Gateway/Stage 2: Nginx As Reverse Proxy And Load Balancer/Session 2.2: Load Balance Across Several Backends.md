## Session 2.2: Load Balance Across Several Backends

### Goal

- Run three `whoami` backends and configure Nginx with an `upstream` pool so requests spread across all three.

### Constraints

- Three identical `whoami` backends, none published.
- One Nginx `upstream` block listing all three.
- Prove the spread by repeated requests.

### Expected result

- Repeated `curl` calls return different backend `Hostname` values, cycling through the three.

## Example

1. Create 3 new `whoamis` backends.

    ```
    docker run -d --name backend1 --network proxy-net traefik/whoami
    docker run -d --name backend2 --network proxy-net traefik/whoami
    docker run -d --name backend3 --network proxy-net traefik/whoami
    ```

2. Configure `my-nginx` to include `upstream` pool.

    ```
    events {}

    http {
        
        # Create this upstream block
        upstream backend-pool { 
            server backend1;
            server backend2;
            server backend3;
        }
        
        server {
            listen 80;

            location / {
                # Change proxy_pass to backend-pool
                proxy_pass http://backend-pool/; 
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }
        }
    }
    ```

3. Launch the new Load Balancer

    Create a container from `nginx` image to `proxy-net` network and mount the newly configured `my-nginx.conf` inside the container.

    ```
    docker run -d -p 8080:80 --name nginx-proxy --network proxy-net -v "$(pwd)/my-nginx.conf:/etc/nginx/nginx.conf" nginx
    ```

4. Test that the Load Balancer is working.

    ```
    curl http://localhost:8080
    ```
    Repeat this command several times to see the output.
    
    Output:

    ![output](https://github.com/user-attachments/assets/c8accd2c-d4ee-4fd9-b024-3f744e3f3c3c)

    Notice that `Hostname` shuffles through not sticking to the same one for each time we use `curl`.

    By default, **Nginx** uses a "round-robin" load-balancing algorithm. The container ID of the backend change perfectly in a cycle from backend1 --> backend2 --> backend3 --> backend1.

## Questions

1. **`curl` Nginx ten times in a row. How many distinct `Hostname` values appear?**

    * There can only be 3 `Hostname` values, since there are only 3 `whoami` backend containers in this proxy-network. 

2. **Stop one backend and keep curling. Do requests still succeed?**

    * Requests still succeed. However, there might be a momentary delay on one request, which is the backend that we stopped, but traffic will continue to flow. **Nginx** will recognize that the backend is unresponsive and distribute the incoming request between the remaining healthy containers. This is based on the principle of **High Availibility**. 

3. **Round-robin sends request N+1 to the next backend regardless of load. When is that a bad strategy, and what alternatives exist (least-conn, IP-hash)?**

    * **`Round-robin`** send requests entirely blind. It does not care how busy or how powerful a server is. It is a bad strategy when the application handles various tasks with different size. It could keep piling requests to the server with higher load while the other one sit completely idle.

    * **`least_conn (Least Connections)`**: counts the number of active open connections on each backend and routes the next request to the server with the lowest number. It is good for applications with variable session lengths or long running process tasks.

    * **`ip_hash (IP Hash)`**: Uses client's IP Address to mathematically calculate a specific backend destination so that the client, in specific, will always be routed to that exact backend. Best for "Sticky sessions" or if your application stores a user's shoping cart or login state locally on the server's memory. 

    * **`hash (Generic Hash)`**: Determines the target server by evaluating a text string, optional request variables, or a combination of both. Used for Custom session persistance or caching. Can be hash by specific cookie, request URI, or request headers.
    * **`random (Random)`** Used for highly distributed environmnets or when using multiple load balancers that do not share absolute server states.
