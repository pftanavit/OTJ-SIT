# Linux Services & Logging Mega Lab

## Goal

Build a small application service and troubleshoot it.

This lab focuses on:

```text
systemctl
journalctl
ps
kill
grep
tail
cat
```

Required structure:

```text
linux-service-lab
├── app
│   ├── app.sh
│   ├── app.log
│   └── app.service
├── logs
│   ├── startup.log
│   ├── error.log
│   └── access.log
└── reports
    ├── service-status.txt
    └── recent-errors.txt
```

---

# Service Requirements

Create a service named:

```text
demo-app
```

The service must support:

```text
Start
Stop
Restart
Enable
Disable
```

Verification:

```bash
systemctl status demo-app
```

Expected output should contain:

```text
active (running)
```

---

# Application Script

## app/app.sh

Running the application should continuously write log entries.

The process must remain running until stopped through the service.

Verification:

```bash
ps -ef
```

Must show a running process associated with the service.

---

# Log Files

## logs/startup.log

Content:

```text
INFO Application Starting
INFO Loading Configuration
INFO Service Ready
```

Verification:

```bash
cat logs/startup.log
```

Expected output:

```text
INFO Application Starting
INFO Loading Configuration
INFO Service Ready
```

---

## logs/error.log

Content:

```text
ERROR Database Timeout
ERROR DNS Lookup Failed
ERROR Connection Refused
```

Verification:

```bash
cat logs/error.log
```

Expected output:

```text
ERROR Database Timeout
ERROR DNS Lookup Failed
ERROR Connection Refused
```

---

## logs/access.log

Content:

```text
GET /
GET /health
POST /login
GET /metrics
```

Verification:

```bash
cat logs/access.log
```

Expected output:

```text
GET /
GET /health
POST /login
GET /metrics
```

---

# Service Status Report

Create:

```text
reports/service-status.txt
```

The file must contain service status information.

Verification:

```bash
cat reports/service-status.txt
```

Expected output should contain information such as:

```text
Loaded
Active
Main PID
```

---

# Error Report

Create:

```text
reports/recent-errors.txt
```

The file must contain only:

```text
ERROR Database Timeout
ERROR DNS Lookup Failed
ERROR Connection Refused
```

Verification:

```bash
cat reports/recent-errors.txt
```

Expected output:

```text
ERROR Database Timeout
ERROR DNS Lookup Failed
ERROR Connection Refused
```

---

# Process Requirement

A process must be running for the service.

Verification:

```bash
ps -ef
```

Expected output should include the application process.

---

# Log Investigation Requirement

A command should be able to return:

```text
ERROR DNS Lookup Failed
```

from the available log files.

---

# Journal Requirement

The service must write entries visible through:

```bash
journalctl
```

Verification:

```bash
journalctl -u demo-app
```

Expected output should contain service log entries.

---

# Service Restart Verification

Restart the service.

Verification:

```bash
systemctl restart demo-app
systemctl status demo-app
```

Expected output:

```text
active (running)
```

---

# Service Enable Verification

Enable the service.

Verification:

```bash
systemctl is-enabled demo-app
```

Expected output:

```text
enabled
```

---

# Service Disable Verification

Disable the service.

Verification:

```bash
systemctl is-enabled demo-app
```

Expected output:

```text
disabled
```

---

# Failure Scenario

Create a second service named:

```text
broken-app
```

The service must fail when started.

Verification:

```bash
systemctl status broken-app
```

Expected output should contain:

```text
failed
```

---

# Failure Investigation

Determine the cause of the failure using:

```bash
journalctl -u broken-app
```

The failure reason should be visible in the logs.

---

# Final Verification

Directory structure:

```bash
tree linux-service-lab
```

Expected output:

```text
linux-service-lab
├── app
│   ├── app.log
│   ├── app.service
│   └── app.sh
├── logs
│   ├── access.log
│   ├── error.log
│   └── startup.log
└── reports
    ├── recent-errors.txt
    └── service-status.txt
```

---

# Verification Commands

```bash
systemctl status demo-app

journalctl -u demo-app

journalctl -u broken-app

ps -ef

cat logs/startup.log

cat logs/error.log

cat logs/access.log

cat reports/service-status.txt

cat reports/recent-errors.txt
```

All commands should complete successfully and produce the expected output.

---

# Skills Covered

```text
Systemd Services
Service Lifecycle Management
Process Management
Service Enablement
Service Failure Analysis
System Logging
Journalctl
Log Collection
Log Searching
Operational Troubleshooting
Linux Service Administration
```

## Commands Used
**`cat << 'EOF' | sudo tee /etc/systemd/system/demo-app.service > /dev/null`**:

* `sudo tee`: Writes the multi-line configuration directly into the highly restricted `/etc/systemd/system/` directory where Linux expects to find background service files.

* `> /dev/null`: Silences the terminal output so the text isn't printed back to your screen.

**`sudo systemctl daemon-reload`**:

* `systemctl`: The core command-line utility for controlling the systemd system and service manager.

* `daemon-reload`: Instructs the systemd manager to rescan the system directories and rebuild its internal dependency tree. This must be run every time you create or modify a .service file.

**`sudo systemctl start demo-app`**:

* `start`: Immediately spins up the background process defined in your service file.

**`sudo systemctl restart demo-app`**:

* `restart`: Safely stops the currently running service and instantly starts it back up. Crucial for applying updates if you modify the underlying script (`app.sh`).

**`systemctl status demo-app`**:

* `status`: Retrieves the current state of the service. It tells you if it is `active` (`running`), `failed`, or `inactive`, along with the Main PID (Process ID) and the last few lines of its system logs.

**`sudo systemctl enable demo-app`**:

* `enable`: Reads the `WantedBy=` line in the service file and creates a symbolic link so the service automatically starts every time the Linux server boots up.

**`journalctl -u demo-app -n 20 --no-pager`**:

* `journalctl`: The central tool for querying system and service logs.

* `-u demo-app`: Filters the massive system journal to only show logs generated by the demo-app unit.

* `-n 20`: Limits the output to only the 20 most recent lines.

* `--no-pager`: Prints the logs directly to the terminal screen instead of trapping you in a scrollable view.

**`sudo journalctl --vacuum-time=5m`**:

* `--vacuum-time=5m`: Deletes old, archived systemd logs to free up space, keeping only the logs from the last 5 minutes.

**`chmod +x /home/ubuntu/linux-sevice-lab/app/app.sh`**:

* `chmod`: Changes file permissions.

* `+x`: Adds the "execute" permission. Systemd will fail with a `status=3/FAILURE` (Permission Denied) if the script it is trying to run via `ExecStart=` is not marked as executable.

**`sudo chmod 777 /home/ubuntu/linux-sevice-lab/reports/`**:

* `777`: Grants universal read, write, and execute permissions to a directory. Used here to guarantee that the systemd service (which might run as a different user) is allowed to write its status reports into the folder.