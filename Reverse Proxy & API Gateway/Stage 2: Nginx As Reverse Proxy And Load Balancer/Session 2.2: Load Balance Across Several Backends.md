## Session 2.2: Load Balance Across Several Backends

### Goal

- Run three `whoami` backends and configure Nginx with an `upstream` pool so requests spread across all three.

### Constraints

- Three identical `whoami` backends, none published.
- One Nginx `upstream` block listing all three.
- Prove the spread by repeated requests.

### Expected result

- Repeated `curl` calls return different backend `Hostname` values, cycling through the three.
