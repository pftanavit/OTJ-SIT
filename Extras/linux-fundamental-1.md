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


# Commands Used

* **`mkdir -p linux-lab/{app,logs,backup,archive,scripts}`**: 

    * `mkdir`: Make directory. 
    * `-p` Tells `mkdir` to create any necessary parent directories adn prevents the command from throwing an error if the directory already exists.
    * `{app,logs,backup,archive,scripts}`: "Brace Expansion". Acts as a shortvut to create all five directories at the same time inside `linux-lab`.

* **`cat << 'EOF' > app/config.yaml`**: 
    * `cat` short for "concatenate". Normally used to read files, but when comibne with other operators allow writing them.
    * `<< 'EOF'`: "Here Document" (Heredoc). Tells the terminal to take in multi-line text and pass it to the command until it see the exact `EOF` (End of File) preventing it from executing any special characters.

* **`chmod +x app/app.sh`**:
    * "Change Mode". `+x` is used to add executable permissions allowing the system to run the file as a script or program.


* **`cp app/config.yaml backup/`**:
    
    * "Copy". Duplicates a file from the first path provided and places the copy in the second path.

* **`tar -czf archive/backup.tar.gz -C backup config.yaml app.log`**

    * `tar`: Stands for "tape archive." It is the standard Linux utility for bundling multiple files into a single archive file.

    * `-czf`: These are three flags combined. `-c` creates a new archive, `-z`compresses it using gzip (making it a `.tar.gz` file), and `-f` specifies that the very next word is the name of the file you are creating.

    * `-C`: This flag tells `tar` to temporarily change its working directory to the specified path (like `backup/`) before grabbing the files. This ensures your archive only contains the files themselves, rather than the entire `backup/` folder structure.

* **`grep "ERROR" logs/app.log`**:

    * Stands for "global regular expression print." It scans through a file or text output looking for a specific pattern (like "ERROR") and prints only the lines that contain a match.

* **`echo "IP Address: $(hostname -I | awk '{print $1}')" > app/network.txt`**

    * `hostname -I`: Retrieves all network IP addresses assigned to the machine.

* **`echo "Default Gateway: $(ip route | grep default | awk '{print $3}')" >> app/network.txt`**

    * `ip route`: Displays the system's IP routing table, which is used here to find where default network traffic is sent.

* **`echo "DNS Server: $(grep nameserver /etc/resolv.conf | awk '{print $2}' | head -n 1)" >> app/network.txt`**

    * `grep nameserver /etc/resolv.conf`: finds the DNS that is located in `etc/resolve.conf`
    * `head -n 1`: Takes the block of text and only outputs the very first line (`-n 1`), discarding the rest.

* **`awk '{print $1}'`**: `awk` is a powerful text-processing language. In these commands, it is used to grab specific columns of text from a larger output (e.g., printing the 1st or 3rd word in a sentence separated by spaces).

* **`sleep 300 &`**: 

    * `sleep`: Tells the terminal to pause and do nothing for a specified amount of time (in seconds).

    * `&`: When placed at the very end of a command, the ampersand pushes that task into the "background." This allows the process to keep running silently while immediately giving you your terminal prompt back to type new commands.