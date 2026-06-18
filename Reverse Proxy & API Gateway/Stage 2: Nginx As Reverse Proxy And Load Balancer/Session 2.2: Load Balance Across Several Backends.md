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

    By default, **Nginx** uses a "round-robin" load-balancing algorithm. The container ID of the backend change perfectly in a cycle from backend1 --> backend2 --> backend3 --> backend1.