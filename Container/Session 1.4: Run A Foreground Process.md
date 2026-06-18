# Session 1.4: Run A Foreground Process
### Goal:
- Start a base OS container that keeps running by running a long-lived foreground command.

### Constraints:
- Use only ubuntu.
- Do not use sleep infinity until you try at least one other approach.
- Explain why the container stops when the main command exits.
  
### Expected results:
- The learner can keep a container running.
- The learner understands that a container is tied to its main process.

## Example

Try creating a standard container. 

```
docker run -it ubuntu
```
* **-i:** (Interactive) tells Docker to keep the standard input (STDIN) open, allowing you to send keyboard commands into the container.
* **-t:** (TTY) Allocates a pseudo-terminal, which gives you that nice formatted command prompt (like `root@container_id:/#`).

When running `docker run -it ubuntu`, Docker looks at the Ubuntu image, sees its default command is `bash`, and boots up a `bash` shell as PID 1. 

What this means is that the container's entire existence is now tied to the active keyboard session. If the terminal window is closed, or type `exit`, that `bash` process (PID 1) terminates.

Try to create a container that keeps running.

Using `while` loop:
```
docker run -d --name while-loop ubuntu bash -c "while true; do date; sleep 2; done"
```
Check:
```
docker ps
```
Output:
```
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS     NAMES
c535b4fd2e23   ubuntu    "bash -c 'while true…"   2 minutes ago   Up 2 minutes             while-loop
```

Now look at the logs:
```
docker logs while-loop
```
Output:
```
Tue Jun  9 03:41:43 UTC 2026
Tue Jun  9 03:41:45 UTC 2026
Tue Jun  9 03:41:47 UTC 2026
Tue Jun  9 03:41:49 UTC 2026
Tue Jun  9 03:41:51 UTC 2026
Tue Jun  9 03:41:53 UTC 2026
Tue Jun  9 03:41:55 UTC 2026
Tue Jun  9 03:41:57 UTC 2026
Tue Jun  9 03:41:59 UTC 2026
Tue Jun  9 03:42:01 UTC 2026
Tue Jun  9 03:42:03 UTC 2026
Tue Jun  9 03:42:05 UTC 2026
Tue Jun  9 03:42:07 UTC 2026
Tue Jun  9 03:42:09 UTC 2026
Tue Jun  9 03:42:11 UTC 2026
Tue Jun  9 03:42:13 UTC 2026
Tue Jun  9 03:42:15 UTC 2026
Tue Jun  9 03:42:17 UTC 2026
```

This container is now running infinitely in the background using a `while` loop which makes it print the date every 2 seconds. 

This method works, however, notice that it consumes CPU in the background.

Now try creating a container that keeps running using the command `sleep infinity`

```
docker run -d --name infinite-container ubuntu sleep infinity
```
Now check the status:
```
docker ps
```
Output:
```
CONTAINER ID   IMAGE     COMMAND            CREATED         STATUS         PORTS     NAMES
cc6bb6e44466   ubuntu    "sleep infinity"   2 seconds ago   Up 2 seconds             infinite-container
```
The container is now running in the background infinitely. Using 0% CPU.

To enter the container: 
```
docker exec -it infinite-container bash
```
Now exit the container.
```
exit
```
Check the status again:
```
docker ps
```
Output:
```
CONTAINER ID   IMAGE     COMMAND            CREATED         STATUS         PORTS     NAMES
cc6bb6e44466   ubuntu    "sleep infinity"   2 minutes ago   Up 2 minutes             infinite-container
```

The container is still running after exiting.

To remove the container, try `docker rm`

```
docker rm infinite-container
```
Output:
```
Error response from daemon: cannot remove container "infinite-container": container is running: stop the container before removing or force remove
```

So,
```
docker stop infinite-container
docker rm infinite-container
```
Check:
```
docker ps
```
Output:
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

Shortcut:
```
docker rm -f infinite-container
```
This skips the two-step process and force-delete a container using -f flag.

## Explanation

* `docker run` creates a new container. When that command was executed with `sleep infinity`, it then became `PID1` and as long as it is running, the container will live.
* `docker exec` starts a new process inside the already running container. Since it is not `PID1`, you can start it, work in it, exit it, without affecting the container.

## Questions

1. **What was the main process?**

    * The main process was the specific command passed to Docker when started the container. For example, in the previous steps, it was `bash`, `while` loop, or `sleep infinity`.
2. **What happened when the process ended?**

    * When the process ended, the container shuts down and transitions to the `Exited` state.
3. **Why is a container not the same as a full virtual machine?**

    * A virtual Machine (VM) boots up an entire operating system and hundreds of systems in the background. As opposed to a container in which it isolates around the application process itself.
4. **Run `ps -ef` inside the container. Which process shows as PID 1?**
    
    ```text
    UID        PID  PPID  C STIME TTY          TIME CMD
    root         1     0  0 04:29 ?        00:00:00 sleep infinity
    root         7     0  0 04:29 pts/0    00:00:00 bash
    root        14     7  0 04:29 pts/0    00:00:00 ps -ef
    ```
    * `sleep infinity` is the `PID1` 

5. **On a normal Ubuntu machine PID 1 is `systemd`. Here PID 1 is your own command. What does that tell you about what a container really is?**

    * A container is not booting an operating system. It is simply jus the raw application running on the machine.
6. **What does adding `&` to a command do, and why could that make the container exit right away?**

    * Adding an ampersand (`&`) to the end of a command forces the Linux shell to push that task into the background and immediately move on to the next line of code. In Docker, this causes the container to exit immediately. For example, if you `run docker run -d --name background-trap ubuntu bash -c "sleep infinity &"`, Docker assigns the bash `shell` as `PID1`. The `shell` reads the script, throws the sleep process into the background, and looks for the next instruction. Because there is no next line of code, the shell (`PID1`) declares its job finished and exits. Since a container only lives as long as its main process, Docker immediately shuts the entire container down.
