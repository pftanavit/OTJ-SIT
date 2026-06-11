# Linux Fundamentals Mega Lab

## Goal

Build the following environment from scratch.

```text
linux-lab
├── app
│   ├── config.yaml
│   ├── app.sh
│   └── README.md
├── logs
│   ├── app.log
│   └── access.log
├── backup
│   ├── config.yaml
│   └── app.log
├── archive
│   └── backup.tar.gz
└── scripts
    └── deploy.sh
```

---

## Required File Contents

### app/config.yaml

```yaml
app_name: demo
environment: dev
port: 8080
```

### app/README.md

```text
Demo Application

This application is used for Linux practice.
```

### app/app.sh

```bash
#!/bin/bash

echo "Application Started"
```

Requirements:

* File must be executable.
* Running it should output:

```text
Application Started
```

### logs/app.log

```text
INFO Startup Complete
INFO User Login
WARN Memory Usage High
ERROR Database Connection Failed
```

### logs/access.log

```text
10.0.0.10 GET /
10.0.0.11 GET /login
10.0.0.12 POST /login
10.0.0.13 GET /health
```

### scripts/deploy.sh

```bash
#!/bin/bash

echo "Deployment Started"
```

Requirements:

* File must be executable.
* Running it should output:

```text
Deployment Started
```

---

## Additional Requirements

### Backup

`backup/` must contain copies of:

```text
config.yaml
app.log
```

Contents must be identical to originals.

Verification:

```bash
diff app/config.yaml backup/config.yaml
diff logs/app.log backup/app.log
```

Expected:

```text
(no output)
```

---

### Archive

Create:

```text
archive/backup.tar.gz
```

The archive must contain:

```text
config.yaml
app.log
```

Verification:

```bash
tar -tf archive/backup.tar.gz
```

Expected:

```text
config.yaml
app.log
```

---

### Search Requirement

A command should be able to return:

```text
ERROR Database Connection Failed
```

from `app.log`.

---

### Networking Requirement

Identify and record:

```text
IP Address
Default Gateway
DNS Server
```

Store them in:

### app/network.txt

Example format:

```text
IP Address: x.x.x.x
Default Gateway: x.x.x.x
DNS Server: x.x.x.x
```

Values depend on your machine.

---

### Process Requirement

Start a process that remains running for at least 5 minutes.

Verification:

```bash
ps -ef
```

Output should contain a long-running process.

---

## Final Verification

Running:

```bash
tree linux-lab
```

should produce:

```text
linux-lab
├── app
│   ├── app.sh
│   ├── config.yaml
│   ├── network.txt
│   └── README.md
├── archive
│   └── backup.tar.gz
├── backup
│   ├── app.log
│   └── config.yaml
├── logs
│   ├── access.log
│   └── app.log
└── scripts
    └── deploy.sh
```

And the following should all succeed and produce the indicated output:

```bash
cat app/config.yaml
```

Output:

```text
app_name: demo
environment: dev
port: 8080
```

```bash
cat logs/app.log
```

Output:

```text
INFO Startup Complete
INFO User Login
WARN Memory Usage High
ERROR Database Connection Failed
```

```bash
./app/app.sh
```

Output:

```text
Application Started
```

```bash
./scripts/deploy.sh
```

Output:

```text
Deployment Started
```

```bash
diff app/config.yaml backup/config.yaml
diff logs/app.log backup/app.log
```

Output:

```text
(no output)
```

```bash
tar -tf archive/backup.tar.gz
```

Output:

```text
config.yaml
app.log
```

```
```

## Skills Covered

```text
Filesystem navigation
Directory creation
File creation
File editing
Copying files
Moving files
Permissions
Searching text
Compression
Processes
Networking basics
Verification techniques
```
