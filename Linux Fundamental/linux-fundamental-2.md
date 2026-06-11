# Linux Users, Groups, Permissions & Monitoring Mega Lab

## Goal

Build and configure the following environment.

```text
linux-admin-lab
├── departments
│   ├── developers
│   │   └── app.conf
│   ├── operations
│   │   └── deploy.conf
│   └── shared
│       └── team.txt
├── monitoring
│   ├── processes.txt
│   ├── memory.txt
│   ├── disk.txt
│   └── network.txt
└── scripts
    └── healthcheck.sh
```

---

# User Requirements

Create the following users:

```text
alice
bob
charlie
```

Verification:

```bash
id alice
id bob
id charlie
```

Each command must return valid user information.

---

# Group Requirements

Create the following groups:

```text
developers
operations
```

Verification:

```bash
getent group developers
getent group operations
```

Expected output should contain both groups.

---

# Membership Requirements

Assign:

```text
alice    -> developers
bob      -> operations
charlie  -> developers
```

Verification:

```bash
groups alice
groups bob
groups charlie
```

Expected:

```text
alice : alice developers

bob : bob operations

charlie : charlie developers
```

---

# Directory Ownership Requirements

Ownership must be:

```text
departments/developers -> developers group
departments/operations -> operations group
departments/shared -> developers group
```

Verification:

```bash
ls -ld departments/*
```

Output should show the expected group ownership.

---

# Permission Requirements

## developers directory

Members of developers group:

```text
Read
Write
Execute
```

Others:

```text
No access
```

Verification:

```bash
ls -ld departments/developers
```

Permissions should reflect:

```text
drwxrwx---
```

---

## operations directory

Members of operations group:

```text
Read
Write
Execute
```

Others:

```text
No access
```

Verification:

```bash
ls -ld departments/operations
```

Permissions should reflect:

```text
drwxrwx---
```

---

## shared directory

Members of developers group:

```text
Read
Write
Execute
```

Everyone else:

```text
Read
Execute
```

Verification:

```bash
ls -ld departments/shared
```

Permissions should reflect:

```text
drwxrwxr-x
```

---

# Required File Contents

## departments/developers/app.conf

```text
APP_NAME=demo
ENV=dev
PORT=8080
```

---

## departments/operations/deploy.conf

```text
DEPLOY_ENV=production
REPLICAS=3
```

---

## departments/shared/team.txt

```text
alice
bob
charlie
```

---

# Monitoring Requirements

Create text files containing information gathered from the system.

---

## monitoring/processes.txt

Must contain running process information.

Verification:

```bash
cat monitoring/processes.txt
```

Output should contain multiple running processes.

---

## monitoring/memory.txt

Must contain memory information.

Verification:

```bash
cat monitoring/memory.txt
```

Output should contain values for:

```text
total
used
free
```

---

## monitoring/disk.txt

Must contain filesystem information.

Verification:

```bash
cat monitoring/disk.txt
```

Output should contain:

```text
Filesystem
Size
Used
Avail
```

---

## monitoring/network.txt

Must contain:

```text
IP Address
Default Gateway
DNS Server
```

Example:

```text
IP Address: x.x.x.x
Default Gateway: x.x.x.x
DNS Server: x.x.x.x
```

---

# Process Monitoring Requirement

Start a process that runs for at least 10 minutes.

Verification:

```bash
ps -ef
```

Output should show the running process.

---

# Health Check Script

## scripts/healthcheck.sh

Running the script must produce output similar to:

```text
===== SYSTEM HEALTH =====

Disk Usage
Memory Usage
Running Processes
Network Information
```

Requirements:

* Script must be executable.
* Script must gather live information from the system.

Verification:

```bash
./scripts/healthcheck.sh
```

Should display system status.

---

# Access Validation

Validate the following:

## Alice

Can access:

```text
departments/developers
departments/shared
```

Cannot access:

```text
departments/operations
```

---

## Bob

Can access:

```text
departments/operations
departments/shared
```

Cannot access:

```text
departments/developers
```

---

## Charlie

Can access:

```text
departments/developers
departments/shared
```

Cannot access:

```text
departments/operations
```

---

# Final Verification

Directory structure:

```bash
tree linux-admin-lab
```

Expected:

```text
linux-admin-lab
├── departments
│   ├── developers
│   │   └── app.conf
│   ├── operations
│   │   └── deploy.conf
│   └── shared
│       └── team.txt
├── monitoring
│   ├── disk.txt
│   ├── memory.txt
│   ├── network.txt
│   └── processes.txt
└── scripts
    └── healthcheck.sh
```

---

# Skills Covered

```text
User Management
Group Management
User Membership
Ownership
Permissions
Access Control
Process Monitoring
Memory Monitoring
Disk Monitoring
Network Monitoring
System Health Checks
Troubleshooting Access Issues
Linux Administration Fundamentals
```
