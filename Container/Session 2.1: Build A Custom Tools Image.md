# Session 2.1: Build A Custom Tools Image
### Goal:
- Create a Dockerfile from ubuntu that installs curl and runs curl --version by default.

### Constraints:
- Base image must be ubuntu.
- Use a Dockerfile.
- The final image must run without manually entering the container.

### Expected results:
- docker build creates a custom image.
- docker run executes the default command.

## Example

1. **Create a new folder**
2. **Create a new plain text file. Name the file `Dockerfile`.**

    ```
    FROM ubuntu

    RUN apt-get update && apt-get install -y curl

    CMD ["curl", "--version"]
    ```

3. **Build the Custom Image.**

    Open the terminal in that folder and run the command:
    ```
    docker build -t custom-curl .
    ```

4. **Run the `custom-curl` Dockerfile.**

    ```
    docker run custom-curl
    ```

    Output:
    ```
    curl 8.18.0 (aarch64-unknown-linux-gnu) libcurl/8.18.0 OpenSSL/3.5.5 zlib/1.3.1 brotli/1.2.0 zstd/1.5.7 libidn2/2.3.8 libpsl/0.21.2 libssh2/1.11.1 nghttp2/1.68.0 librtmp/2.3 mit-krb5/1.22.1 OpenLDAP/2.6.10
    Release-Date: 2026-01-07, security patched: 8.18.0-1ubuntu2.1
    Protocols: dict file ftp ftps gopher gophers http https imap imaps ipfs ipns ldap ldaps mqtt pop3 pop3s rtmp rtsp scp sftp smb smbs smtp smtps telnet tftp ws wss
    Features: alt-svc AsynchDNS brotli GSS-API HSTS HTTP2 HTTPS-proxy IDN IPv6 Kerberos Largefile libz NTLM PSL SPNEGO SSL threadsafe TLS-SRP UnixSockets zstd
    ```

## Questions

1. **Which steps happen during docker build?**

    * During `docker build`, Docker executes `FROM` and `RUN`. 
    
        * `FROM ubuntu`: Docker downloads and extract layers from ubuntu.  
        * `RUN apt-get update && apt-get install -y curl`: Docker starts a temporary container and runs the installation commands, captures the `curl` files, then turn it into a new permanent image layer.
2. **Which command runs during docker run?**
    * During `docker run`, the `CMD` is executed.
        ```
        curl --version
        ```

3. **Why is this better than manually installing curl every time?**

    * This process eliminates human error, also you only need to build once and it can create a new container from that image in a much shorter amount of time.

4. **Run the image, then docker run -it <image> bash and whoami. Which user do build steps and the container run as?**

    *   ```
        docker run -it custom-curl bash
        whoami
        ```
        Output:
    *   ```
        root
        ```
    Docker executes all `RUN` steps during the build and runs the final container environment as the root superuser.
    
5. **In your Dockerfile, apt install uses -y. Try removing it and rebuilding. What happens?**
    
    Result:
    *   ```
            7.530 Do you want to continue? [Y/n] Abort.
            ------
            Dockerfile:3
            --------------------
               1 |     FROM ubuntu
               2 |     
               3 | >>> RUN apt-get update && apt-get install curl
               4 |     
               5 |     CMD ["curl", "--version"]
            --------------------
            ERROR: failed to build: failed to solve: process "/bin/sh -c apt-get update && apt-get install curl" did not complete successfully: exit code: 1
        ```
        `Docker build` is an automated process, so once it asks permission to continue? [Y/n], `-y` stands for Yes. Because there is no answer in this automated process, it fails and `abort`.

6. **Each RUN runs as root in a shell. Why does that matter for who owns the files it creates?**

    * Because every `RUN` command executed as `root`is owned by `root`. `root` owns the build outputs and can change permission for other users.

7. **Why do we chain apt update && apt install on one line with &&?**

    * This is done due to **Layer Caching Optimization**. Chaining them ensures that both of them is done together in one step. Since, Docker treat each `RUN` command separately, if separated Docker might reuse `apt update` that was previously created, causing problems and may crash the build.
