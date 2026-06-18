# Session 3.3: Run A Simple HTTP Server From A Base Image

### Goal:

* Use an Ubuntu-based Dockerfile to install a small HTTP server tool and serve a file from `/app/public` on a host port.

### Constraints:

* Base image must be ubuntu.
* Do not use the nginx, httpd, node, or python base image.
* Install the required package yourself.
* Publish the container port to the host.

### Expected result:
* A browser or curl on the host can reach the file served by the container.

## Example

1. Create a folder and make a `Dockerfile`. 

    ```
    FROM ubuntu

    RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

    WORKDIR /app/public

    RUN echo "<h1>Hello from the custom Ubuntu HTTP server!</h1>" > index.html

    EXPOSE 8000

    CMD ["python3", "-m", "http.server", "8000"]
    ```
2. Build the custom image.

    ```
    docker build -t custom-server .
    ```

3. Run and publish the port from a container.

    Because a container is isolated, the web server created inside is trapped and the machine cannot see its traffic.

    To tackle this, use `-p` (publish) to map the container's network wall to the machine.

    ```
    docker run -d -p 8080:8000 --name my-server custom-server
    ```

4. Test the web server.
    
    1.) Use `curl`.
        
    ```
    curl http://localhost:8080
    ```
    Output:
    ```
    <h1>Hello from the custom Ubuntu HTTP server!</h1>
    ```

    2.) Try with browser.

        Visit http://localhost:8000/

    Result:
    ![example-browser](https://github.com/user-attachments/assets/f01567ef-6909-4ebb-8c03-43d5532e2b6b)

   _Docker `EXPOSE`_: https://dhavalgojiya.hashnode.dev/understanding-dockers-expose-keyword-4-port-mapping-scenarios-explained
   
