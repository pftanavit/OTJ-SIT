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
