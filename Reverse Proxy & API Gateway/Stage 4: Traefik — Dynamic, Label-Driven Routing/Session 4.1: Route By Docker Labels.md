# Session 4.1: Route By Docker Labels

### Goal:

- Run `traefik` configured with the Docker provider. Add the `whoami` backend with Traefik **labels** so Traefik discovers it and routes to it by hostname — without you writing any route file.

### Constraints:

- Use the official `traefik` image.
- Traefik must read routes from the Docker provider (it needs access to the Docker socket).
- The route (host rule, port) is declared as **labels on the backend container**, not in a static config file.
- Enable the Traefik dashboard to observe discovered routes.

### Expected results:

- A request with the right `Host` header reaches the backend via Traefik.
- The Traefik dashboard shows the route that was discovered from the labels.