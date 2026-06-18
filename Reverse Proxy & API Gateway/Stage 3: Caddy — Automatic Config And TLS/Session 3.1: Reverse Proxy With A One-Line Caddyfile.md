## Session 3.1: Reverse Proxy With A One-Line Caddyfile

### Goal:

- Use a `caddy` container to reverse-proxy to the `whoami` backend with a minimal Caddyfile, and serve it over HTTPS using Caddy's local/internal certificate.

### Constraints:

- Use the official `caddy` image.
- The reverse-proxy directive should be a single line in the Caddyfile.
- Enable TLS using Caddy's internal/local CA (no public domain needed for the lab).

### Expected results:

- `curl` (with the internal CA trusted, or `-k` for the lab) over HTTPS returns the whoami output.
- The learner can show the one-line `reverse_proxy` directive.
