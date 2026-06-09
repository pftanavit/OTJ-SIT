## Session 1.4: Run A Foreground Process
**Goal:**
- Start a base OS container that keeps running by running a long-lived foreground command.

**Constraints:**
- Use only ubuntu.
- Do not use sleep infinity until you try at least one other approach.
- Explain why the container stops when the main command exits.
  
**Expected result:**
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

What this means is that the container's entire existence is now tied to the active keyboard session. If the terminal window is closed, or Wi-Fi connection is lost, or type `exit`, that `bash` process (PID 1) terminates.

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
The container is now running in the background infinitely. 

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

## Explaination

* `docker run` creates a new container. When that command was executed with `sleep infinity`, it then became `PID1` and as long as it is running, the container will live.
* `docker exec` starts a new process inside the already running container. Since it is not `PID1`, you can start it, work in it, exit it, without afftecting the container.
