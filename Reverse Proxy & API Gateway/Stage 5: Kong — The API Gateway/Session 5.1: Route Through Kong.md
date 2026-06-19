# Session 5.1: Route Through Kong

### Goal:

- Run `kong` in DB-less mode with a declarative config that defines a **Service** (the `whoami` backend) and a **Route** to it. Reach the backend through Kong.

### Constraints:

- Use the official `kong` image in DB-less / declarative mode (a `kong.yml` file, no Postgres).
- Define one Service and one Route.
- Only Kong is published; the backend stays internal.

### Expected result

- `curl` to Kong's proxy port, matching the route, returns the whoami output.
