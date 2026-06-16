# Session 3.1: Bind Mount Host Files
**Goal**:
* Run an Ubuntu container that reads and writes files in a host directory using a bind mount.

**Constraints**:
* Use only ubuntu.
* Use a host directory named shared.
* Create one file from the host and one file from the container.
* Prove both sides can see the files.

**Expected result**:
* Host and container share files through a mounted directory.

## Example

1. Create a new folder on host machine name `shared`.

2. Create a text file `host-file.txt`.

    ```
    Hello from host.
    ```

3. Start a brand new container with a Bind Mount.

    ```
    docker run -it -v "$(pwd):/app" ubuntu bash
    ```
4. check `/app`

    ```
    cd /app
    ls -la
    ```
    Output:
    ```
    total 8
    drwxr-xr-x 3 root root   96 Jun 16 07:17 .
    drwxr-xr-x 1 root root 4096 Jun 16 07:20 ..
    -rw-r--r-- 1 root root   16 Jun 16 07:13 host-file.txt
    ```
5. Create another text file from inside the container name `container-text.txt`.
    ```
    echo "Hello from inside container." > container-text.txt
    ```
6. Exit and view the folder on your host machine.

    ```
    exit
    ```
    ![example](https://github.com/user-attachments/assets/cd624c82-2929-43b8-9721-ce72a7d2d6e1)

7. Start up the same container again  and view the files.

    ```
    docker start -i <container_id>
    cd app
    ls
    ```
    Output:
    ```
    container-text.txt  host-file.txt
    ```

## Questions

1. **Which path is on the host, which one is inside the container?**

    * From the command `-v "$(pwd):/app"`: 
        
        * The _Host_ path is always on the **left** side of the colon. (`$(pwd)`) 
        * The _Container_ path is always on the **right** side of the colon. (`/app`) 

2. **What happens if the host directory does not exist?**

    * If the host directory does not exist, Docker will automatically create it as an empty directory on your host machine.
3. **Why might the file be owned by root on the host?**

    * Because the process running inside the container (`ubuntu bash shell`) is operating as root by default. Therefore when we created the file, the container's root user created it.
4. **A UID is just a number. How can the same number be "root" inside the container but a normal user on the host?**

    * User IDs or (UIDs) are pure numbers. The translation from a number to name happens using a dictionary file located at `/etc/passwd`. Because the container and the host have completely isolated file systems, they have different dictionary files. The same UID inside the container and outside may give different names.

    * Normally, `UID 0` is `root`. Docker has a feature called User Namespaces (`userns-remap`). This lets the container thinks that it is using `UID 0` to enable it to operate inside its sandbox. However, if it tries to write a file to host, the Linux intercepts it and translates it to a high number with no privileges to the host. This helps with security and keeps the process completely __isolated__ within the container.
