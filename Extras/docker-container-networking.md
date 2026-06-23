# Docker Networking and Terminology

### Here are some of the outputs from Reverse Proxy & API Gateway:
| | |
| :---: | :---: |
| ![output 1](https://github.com/user-attachments/assets/5d59e390-60c4-46af-91d2-54a39d5ce8ba) <br> **Session 0.1** | ![output 2](https://github.com/user-attachments/assets/3becb16c-9aa6-44ff-81da-d9e9ec7db2ba) <br> **Session 1.1** |
| ![output 3](https://github.com/user-attachments/assets/5535edd3-0ce3-42a9-98e2-0927e6ce9897) <br> **Session 2.1** | ![output 4](https://github.com/user-attachments/assets/ac1eefc1-9d37-46b2-bd30-a7f71f284b23) <br> **Session 3.1** |
| ![output 5](https://github.com/user-attachments/assets/57906951-9f57-47d8-83ca-6fe309d827b0) <br> **Session 4.1** | ![output 6](https://github.com/user-attachments/assets/0d44b662-ad50-492a-b566-c9340960094e) <br> **Session 5.1** |
| ![output 7](https://github.com/user-attachments/assets/c1cad69e-412a-406c-97c5-60e978aa69ed) <br> **Session 5.2** | ![output 8](https://github.com/user-attachments/assets/fe740dbb-b445-4d74-a617-ad6a712510f0) <br> **Session 6.1** |

## Overview
 
All outputs come from a **whoami-style HTTP service** running inside a Docker container. It reports:
- Its own hostname and network interface IPs
- `RemoteAddr` — the IP of whoever made the direct TCP connection to it
- All HTTP request headers it received
---
 
## Output Comparison Table
 
| # | Proxy | Hostname | Container IP | RemoteAddr | X-Forwarded-For | Notable Headers |
|---|---|---|---|---|---|---|
| 1 | None (direct) | `8f95465facb0` | `172.17.0.2` | `192.168.65.1` | — | None |
| 2 | Traefik | `2d5ac125bfca` | `172.19.0.2` | `172.19.0.3` | `192.168.65.1` | X-Forwarded-Host, X-Forwarded-Server |
| 3 | Nginx | `2d5ac125bfca` | `172.19.0.2` | `172.19.0.3` | `172.19.0.1` | X-Forwarded-For only |
| 4 | Caddy | `856e6681f4b5` | `172.19.0.2` | `172.19.0.3` | `172.19.0.1` | Via: 2.0 Caddy, X-Forwarded-Proto: https |
| 5 | Traefik (domain) | `9c926d70184c` | `172.19.0.3` | `172.19.0.2` | `192.168.65.1` | X-Forwarded-Port: 80, X-Forwarded-Server |
| 6 | Kong (req 1) | `4212a98543c9` | `172.19.0.2` | `172.19.0.3` | `192.168.65.1` | X-Kong-Request-Id, X-Forwarded-Path/Prefix |
| 7 | Kong (req 2) | `4212a98543c9` | `172.19.0.3` | `172.19.0.2` | `192.168.65.1` | Same as #6, IP roles swapped |
| 8 | Traefik | `3acd6c0a3736` | `172.20.0.2` | `172.20.0.3` | `192.168.65.1` | X-Forwarded-Port: 80, X-Forwarded-Server |
 
---
 
## Individual Output Breakdowns
 
### Output 1 — No Proxy (Direct Connection)
 
```
Hostname: 8f95465facb0
IP: 172.17.0.2          ← default Docker bridge network
RemoteAddr: 192.168.65.1:19448
Host: localhost:8080
```
 
- The backend was hit **directly** with no middleware
- `RemoteAddr` is `192.168.65.1` — the Docker Desktop host gateway (your Mac/Windows machine)
- Uses the **default bridge** (`172.17.x.x`) — plain `docker run` with no named network
- **No `X-Forwarded-*` headers** — the raw request arrived unmodified
- `Host: localhost:8080` — the client specified the port explicitly
---
 
### Output 2 — Traefik Reverse Proxy
 
```
Hostname: 2d5ac125bfca
IP: 172.19.0.2          ← user-defined compose network
RemoteAddr: 172.19.0.3  ← Traefik container
Host: my-backend
X-Forwarded-For: 192.168.65.1
X-Forwarded-Host: localhost:8080
X-Forwarded-Server: 172.19.0.3
Connection: Keep-Alive
```
 
- First appearance of the **user-defined `172.19` network** — compose stack with named network
- `RemoteAddr` is Traefik (`.3`), not the original client
- `Host: my-backend` — Traefik rewrote the Host header to the backend service name
- Traefik preserved the real client IP in `X-Forwarded-For`
- `X-Forwarded-Server` identifies the Traefik container itself (unique to Traefik)
---
 
### Output 3 — Nginx Reverse Proxy
 
```
Hostname: 2d5ac125bfca   ← same backend container as Output 2
IP: 172.19.0.2
RemoteAddr: 172.19.0.3   ← Nginx container
Host: localhost
X-Forwarded-For: 172.19.0.1
```
 
- Same backend as Output 2 — different proxy, same target
- `X-Forwarded-For` shows `172.19.0.1` (Docker **network gateway**), not the host machine IP
  - Nginx forwarded the gateway IP rather than trusting the original client IP through
- **Minimal headers** — Nginx only added `X-Forwarded-For` by default; no `X-Forwarded-Host`, no `X-Forwarded-Server`
- `Host: localhost` — Nginx passed through the base hostname without port
---
 
### Output 4 — Caddy Reverse Proxy
 
```
Hostname: 856e6681f4b5   ← different backend container
IP: 172.19.0.2
RemoteAddr: 172.19.0.3   ← Caddy container
Host: localhost
Via: 2.0 Caddy
X-Forwarded-For: 172.19.0.1
X-Forwarded-Host: localhost
X-Forwarded-Proto: https
Accept-Encoding: gzip
```
 
- Different backend than Outputs 2 & 3
- `Via: 2.0 Caddy` — Caddy identifies itself in the standard `Via` header (HTTP/2 capable)
- `X-Forwarded-Proto: https` — Caddy was handling TLS termination
- `X-Forwarded-For` is `172.19.0.1` (gateway), same as Nginx — not the real client IP
- `Accept-Encoding: gzip` — **Caddy added this itself**, requesting compressed responses from the backend even if the original curl didn't ask
---
 
### Output 5 — Traefik with Domain-Based Routing
 
```
Hostname: 9c926d70184c   ← new backend container
IP: 172.19.0.3           ← note: .3, not .2
RemoteAddr: 172.19.0.2   ← Traefik is .2 here (roles swapped vs Output 2)
Host: whoami.localhost
X-Forwarded-For: 192.168.65.1
X-Forwarded-Host: whoami.localhost
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: beca86b35318
Accept-Encoding: gzip
```
 
- Traefik routed based on **subdomain** (`whoami.localhost`) rather than path
- IP assignments are reversed vs Output 2 — Traefik is `.2`, backend is `.3`; Docker assigned IPs in different startup order
- `X-Forwarded-Port: 80` — explicit port forwarding header (not present in Output 2)
- Most complete set of forwarding headers from Traefik
- `X-Forwarded-For` correctly shows the real host machine IP (`192.168.65.1`)
---
 
### Output 6 — Kong API Gateway (Request 1)
 
```
Hostname: 4212a98543c9
IP: 172.19.0.2
RemoteAddr: 172.19.0.3   ← Kong container
Host: kong-backend
Via: 1.1 kong/3.9.3
X-Forwarded-For: 192.168.65.1
X-Forwarded-Host: localhost
X-Forwarded-Path: /api/whoami
X-Forwarded-Port: 8000
X-Forwarded-Prefix: /api/whoami
X-Forwarded-Proto: http
X-Kong-Request-Id: 77c8395cb2b65f1685c302088582d528
Connection: keep-alive
```
 
- Kong is an **API gateway**, not just a reverse proxy — richer metadata than Traefik/Nginx/Caddy
- `Via: 1.1 kong/3.9.3` — Kong identifies itself and its version
- `X-Forwarded-Path` and `X-Forwarded-Prefix` — Kong records the original URL path (`/api/whoami`) before any rewriting; unique to Kong
- `X-Kong-Request-Id` — unique per-request trace ID, useful for distributed tracing and log correlation
- `X-Forwarded-Port: 8000` — Kong's default proxy port (not 80 like Traefik)
- `Host: kong-backend` — rewritten to the upstream service name
---
 
### Output 7 — Kong API Gateway (Request 2)
 
```
Hostname: 4212a98543c9   ← same backend as Output 6
IP: 172.19.0.3           ← same container, now assigned .3
RemoteAddr: 172.19.0.2   ← Kong is now .2 (roles swapped vs Output 6)
X-Kong-Request-Id: aeae5b75eed3f915a14ae36ca595a30d   ← different ID
(all other headers identical to Output 6)
```
 
- Same backend container as Output 6 (`4212a98543c9` hostname matches), but IP assignments are reversed
- Docker reassigned `.2` and `.3` between restarts — the **hostname is the stable identifier**, not the IP
- Different `X-Kong-Request-Id` — Kong generates a new UUID for every request
- Confirms Kong's headers are consistent and deterministic across requests
---
 
### Output 8 — Traefik (New Network Stack)
 
```
Hostname: 3acd6c0a3736
IP: 172.20.0.2           ← third distinct Docker network (172.20.x.x)
RemoteAddr: 172.20.0.3   ← Traefik container
Host: localhost
X-Forwarded-For: 192.168.65.1
X-Forwarded-Host: localhost
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: 85e4e340aebf
Accept-Encoding: gzip
```
 
- A **separate Traefik stack** on its own compose network (`172.20.0.x`)
- Same header pattern as Output 5 — full Traefik forwarding set
- `X-Forwarded-For` correctly shows the real host IP (`192.168.65.1`)
- `Accept-Encoding: gzip` — Traefik added this automatically (same behaviour as Output 5)
- Routed by path/port on `localhost` (not a subdomain like Output 5)
---
 
## IP Address Reference
 
| IP | What it is | Seen in |
|---|---|---|
| `127.0.0.1` / `::1` | Loopback (every container always has these) | All outputs |
| `172.17.0.2` | Default Docker bridge — assigned to direct container | Output 1 |
| `172.17.0.1` | Default bridge gateway | (implicit in Output 1) |
| `172.19.0.x` | User-defined compose network #1 | Outputs 2–7 |
| `172.19.0.1` | Docker gateway for the `172.19` network | X-Forwarded-For in Outputs 3 & 4 |
| `172.20.0.x` | User-defined compose network #2 (separate stack) | Output 8 |
| `192.168.65.1` | Docker Desktop host gateway (your Mac/Windows machine) | RemoteAddr in Output 1; X-Forwarded-For in Outputs 2, 5, 6, 7, 8 |
 
---
 
## Key Concepts
 
### RemoteAddr is always the direct TCP peer
The backend always sees the **proxy** as `RemoteAddr`, never the real client. Only in Output 1 (no proxy) does `RemoteAddr` show the actual host machine. The real client IP is only recoverable from `X-Forwarded-For`.
 
### The ephemeral port is noise
The port number in `RemoteAddr` (e.g. `:41526`, `:60618`) is randomly chosen by the OS for each TCP connection. It has no meaningful information.
 
### IP assignments can swap between restarts
Outputs 5 vs 2, and 6 vs 7, show the `.2` / `.3` assignments reversed. Docker assigns IPs in container startup order. The **hostname** (`Hostname:` field) is the stable identifier for a container, not its IP.
 
### `172.19.0.1` vs `192.168.65.1` in X-Forwarded-For
- `192.168.65.1` = **Docker Desktop gateway** — the real origin when curling from your host machine. Traefik and Kong correctly forward this.
- `172.19.0.1` = **Docker network gateway** — Nginx and Caddy forwarded this instead, losing the original client IP. This is a proxy configuration issue, not a Docker limitation.
---