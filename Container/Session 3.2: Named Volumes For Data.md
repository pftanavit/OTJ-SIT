# Session 3.2: Named Volumes For Data

**Goal**:
* Store data in a named Docker volume, remove the container, create a new container, and prove the data still exists.

**Constraints**:
* Use only ubuntu.
* Use a named volume.
* Do not use a bind mount.

**Expected result**:
* Data survives container removal.
* The learner understands why named volumes matter.

## Example

1. Create a named volume.

    ```
    docker volume create named-volume
    ```
2. Create a new container, `container1`, and mount to `named-volume` at `/data`.
    ```
    docker run -it --name container1 -v named-volume:/data ubuntu
    ```
3. Write a text file `data.txt` inside `/data`.
    ```
    echo "Create inside container1" > /data/data.txt
    ```
4. Exit and remove `container1`.
    ```
    exit 
    docker rm container1
    ```
5. Create a new container, `container2`, and mount it to the same volume at `/data`.
    ```
    docker run -it --name container2 -v named-volume:/data ubuntu
    ```
6. Check the folder and files:
    ```
    cd data
    ls
    cat data.txt
    ```
    Output:
    ```
    data.txt
    Create inside container1
    ```
The data that was created inside a container which was attach to a volume will be stored inside a volume. It is still stored even if the container is removed and can be accessed by other containers.

## Questions

1. **Who manages the volume?**
    
    * Docker manages the volume itself. Docker Engine completely takes over the storage management in a named volume. 

2. **Does docker rm delete the volume?**

    * `docker rm` destroys the container. To delete the volume, use `docker volume rm <name>`.

3. **When would you prefer a named volume over a bind mount?**

    * For databases and application state where it does not matter where the files are stored on your physical machine. They are safe, fast, and highly optimized for read/write performance.

4. **Run docker volume inspect `<name>` and find the Mountpoint line. What host path does it show?**
    * ` "Mountpoint": "/var/lib/docker/volumes/named-volume/_data",` 

        It shows `/var/lib/docker/volumes/named-volume/data`. This is where the data is stored on the machine.

5. **Write a file to the volume, then run df -h inside the container. Do you see the volume listed as its own line?**

    * 
        ```
        Filesystem      Size  Used Avail Use% Mounted on
        overlay         453G  2.9G  427G   1% /
        /dev/vda1       453G  2.9G  427G   1% /data
        ```
        
        It is listed inside the container.

6. **The container's writable layer disappears on docker rm, but the volume survives. Why is that difference useful?**
    
    * It is useful because it separates between the container writable container that is temporary and a permanent volume. You can store important information using volumes and create new containers for your condition. For example, application upgrades, you can safely keep your data and create a create a new container with the updated applications. Your data will still be safely kept in the volume. 
