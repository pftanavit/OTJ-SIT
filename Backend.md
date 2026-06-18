# Stage 0: The Backend And The Concept
Establish the fixed backend and the vocabulary before any proxy exists.

## Session 0.1: Run The Backend Alone

**Goal**:
* Run a single traefik/whoami container, publish its port, and reach it directly from the host with curl. Read what it returns.

**Constraints**:
* Use the traefik/whoami image.
* No proxy yet — talk to the backend directly.
* Reach it from the host with curl, not a browser only.

**Expected result**:
* `curl` to the published port returns the whoami output (hostname, IP, headers).
* The learner can point to which line is the container's own hostname.
