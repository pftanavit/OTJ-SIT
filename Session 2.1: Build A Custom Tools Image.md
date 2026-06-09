## Session 2.1: Build A Custom Tools Image
**Goal:**
- Create a Dockerfile from ubuntu that installs curl and runs curl --version by default.

**Constraints:**
- Base image must be ubuntu.
- Use a Dockerfile.
- The final image must run without manually entering the container.

**Expected result:**
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