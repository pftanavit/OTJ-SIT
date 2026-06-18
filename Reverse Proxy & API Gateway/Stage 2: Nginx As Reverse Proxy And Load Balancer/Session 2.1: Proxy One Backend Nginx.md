## Session 2.1: Proxy One Backend With Nginx

### Goal

Replace Apache with an `nginx` container doing the same reverse-proxy job to the single `whoami` backend.

### Constraints:

- Use the official `nginx` image.
- Only Nginx is published; the backend stays internal.
- Write the `proxy_pass` config yourself.

### Expected result:

- `curl` to Nginx returns the whoami output, same as the Apache stage.
