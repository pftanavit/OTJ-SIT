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