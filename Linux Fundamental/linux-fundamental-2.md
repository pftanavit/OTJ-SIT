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

# Commands Used:

* **`mkdir -p departments/{developers,operations,shared}`**: 
    * `mkdir`: "Make Directory." Creates one or more new folders.
    * `-p`: "Parents." Creates any necessary parent directories and prevents errors if the directory already exists.
    * `{...}`: "Brace Expansion." A shortcut to create multiple distinct directories at the exact same time inside the parent folder.

* **`groupadd developers`**: 
    * `groupadd`: Creates a new user group on the system.

* **`useradd -m alice`**: 
    * `useradd`: Creates a new user account on the system.
    * `-m`: Tells the system to automatically create a home directory for the new user (e.g., `/home/alice`).

* **`usermod -aG developers alice`**: 
    * `usermod`: Modifies the properties of an existing user account.
    * `-aG`: A combination of flags. `-G` specifies supplementary groups to add the user to. `-a` (append) ensures the user is added to these new groups *without* being removed from their current ones.

* **`useradd -g developers -m alice`**: 
    * `useradd`: Creates a new user account on the system.
    * `-g developers`: Sets the user's primary/initial login group to `developers`. 
    * `-m`: Automatically creates a home directory for the new user (e.g., `/home/alice`).

* **`chown ubuntu:developers departments/developers`**: 
    * `chown`: "Change Owner." Changes the user and/or group ownership of a file or directory.
    * `ubuntu:developers`: The syntax used to set the user owner (before the colon) to `ubuntu` and the group owner (after the colon) to `developers`.

* **`chown :developers departments/developers`**: 
    
    * `:developers`: By omitting the username before the colon, this strictly changes the **group** ownership to `developers` while leaving the current user owner untouched.

* **`chmod 770 departments/developers`**: 
    * `chmod`: "Change Mode." Modifies file or directory permissions.
    * `770`: Absolute (numeric) permission mode. Grants full read/write/execute access to the User (`7`) and Group (`7`), but strictly denies all access to Others (`0`).

* **`chmod 775 departments/shared`**: 
    * `775`: Grants full read/write/execute access to the User (`7`) and Group (`7`), but restricts Others to only read and execute access (`5`), preventing them from modifying or deleting files.

* **`ps aux > monitoring/processes.txt`**: 
    * `ps`: "Process Status." Displays a snapshot of current active processes.
    * `aux`: Flags that display processes for all users (`a`), show the user/owner of each process (`u`), and include background processes not attached to a terminal (`x`).
    * `>`: Redirects the output to overwrite (or create) the target file.

* **`free -h > monitoring/memory.txt`**: 
    * `free`: Displays the total amount of free and used physical memory (RAM).
    * `-h`: "Human-Readable." Scales the output to easy-to-read units like Megabytes (M) or Gigabytes (G).

* **`df -h > monitoring/disk.txt`**: 
    * `df`: "Disk Free." Displays the amount of available disk space on mounted filesystems.
    * `-h`: "Human-Readable." Scales sizes into powers of 1024 (e.g., Gigabytes).

* **`cat << 'EOF' > scripts/healthcheck.sh`**: 
    * `cat`: Short for "concatenate." Used here to read raw inputs and write them directly into a script file.
    * `<< 'EOF'`: "Here Document" (Heredoc). Instructs the shell to read the upcoming multi-line input block until it hits the exact delimiter string `EOF`. 

* **`chmod +x scripts/healthcheck.sh`**: 
    * `+x`: Adds execute permissions, turning a plain text file into a script or program that the system is allowed to run.

* **`echo "IP Address: $(hostname -I | awk '{print $1}')" >> monitoring/network.txt`**: 
    * `hostname -I`: Retrieves all network IP addresses assigned to the host machine.
    * `awk '{print $1}'`: A text-processing tool used here to isolate and grab the first column/word of the output.
    * `>>`: The append operator. Redirects output to the end of a file without deleting the existing contents.

* **`ip route | grep default | awk '{print $3}'`**: 
    * `ip route`: Displays the system's IP routing table.
    * `grep default`: Scans the output to isolate the line containing the word "default" (the default gateway).
    * `awk '{print $3}'`: Grabs the 3rd piece of text on that line (the actual IP address).

* **`grep nameserver /etc/resolv.conf | awk '{print $2}' | head -n 1`**: 
    * `/etc/resolv.conf`: The system file where local DNS configurations are stored.
    * `head -n 1`: Takes the block of text and only outputs the very first line (`-n 1`), discarding the rest.

* **`sleep 600 &`**: 
    * `sleep`: Pauses the command line execution environment for a specified number of seconds (600 seconds = 10 minutes).
    * `&`: The background operator. Pushes the task into the system background, allowing it to run silently while freeing up your terminal for new commands.