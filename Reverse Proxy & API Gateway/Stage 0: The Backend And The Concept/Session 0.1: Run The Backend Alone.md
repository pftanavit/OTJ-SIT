# Session 0.1: Run The Backend Alone

### Goal:
* Run a single traefik/whoami container, publish its port, and reach it directly from the host with curl. Read what it returns.

### Constraints:
* Use the traefik/whoami image.
* No proxy yet — talk to the backend directly.
* Reach it from the host with curl, not a browser only.

### Expected results:
* `curl` to the published port returns the whoami output (hostname, IP, headers).
* The learner can point to which line is the container's own hostname.

## Example

1. Create a new container from `traefik/whoami` image and publish its port to host machine.

    ```
    docker run -d -p 8080:80 --name my-backend traefik/whoami
    ```

2. Try reaching it with `curl`
    
    ```
    curl http://localhost:8080
    ```
    Output:
    ```
    Hostname: 8f95465facb0
    IP: 127.0.0.1
    IP: ::1
    IP: 172.17.0.2
    RemoteAddr: 192.168.65.1:19448
    GET / HTTP/1.1
    Host: localhost:8080
    User-Agent: curl/8.7.1
    Accept: */*
    ```

* `Hostname`: 8f95465facb0

* `IP`: 

    * IP: 127.0.0.1 (Container)

    * IP: 172.17.0.2 (Bridge)

* `Headers`: curl/8.7.1

## Questions

1. **`curl` the backend twice. Does the Hostname line stay the same?**

    * Yes, the `Hostname` still says the same since it is still the same backend container.

2. **Which header lines are present now, before any proxy exists?**

    * `Host: localhost:8080`: This header identifies the host and port number of the server to which the request is being sent.

    * `User-Agent`: This header identifies the client software, in this case `curl` version 7.81.0

    * `Accept`: This tells the serveer which content types the client is able to understand. (`*/*`)

    
