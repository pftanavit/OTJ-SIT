## Session 2.2: Copy Files Into An Image

**Goal:**
- Create a local text file, copy it into an Ubuntu-based image, and make the container print the file content when it runs.

**Constraints**
- Base image must be ubuntu.
- Use COPY.
- The file must be inside /app.

**Expected result**
- Running the image prints the copied file.
- The learner can identify where the file lives inside the image.

## Example

1. Create a local `note.txt` file.

```
"Hello World"
```
2. Inside the same folder, create a `Dockerfile`.
```
FROM ubuntu

COPY note.txt /app/note.txt

CMD ["cat", "/app/note.txt"]
```
3. Build the Image.
```
docker build -t file-print .
```
4. Start a new container from the image:
```
docker run file-print
```
- Output:
    ```
    "Hello World"% 
    ```
5. Check where the file lives:

Start another container using `file-print` image.
```
docker run -it file-print bash
```
Check the files:
```
cd app
ls
cat note.txt
exit
```
- Output:
    ```
    note.txt
    "Hello World"
    ```
`note.txt` is now inside the container's `/app` folder. It is now completely independent from the `note.txt` that we created on our computer.

## Questions

1. **What files are available to `COPY`?**
    
    * The only files that are available to `COPY` are the ones that are in the same folder that ran `docker build`. Docker cannot access other files that are outside of this folder for security.
2. **Why did we use /app?**

    * Using `/app` is an industry practice. Since in Linux, file systems have their own dedicated folders to them. Dumping your own code into root directory can make things messy and complicated.
3. **What is the difference between a host path and a container path?**

    * Host path and Container path are two different things.

        * `Host Path`: refers to the file system that exist on your physical  device or machine.
        * `Container Path`: refers to the isolated virtual file system that exists within the container/ Docker.
4. **Run docker run -it <image> bash, then ls -l /app. Is your file there? Who owns it?**

    * Output:
        ```
        total 4
        -rw-r--r-- 1 root root 13 Jun 10 08:18 note.txt
        ```
    * The file is there. `root` is the owner. This happens because Docker executes all `Dockerfile` instructions as `root` by default. 
5. **Run pwd inside that shell. Did WORKDIR change where you start?**

    * `WORKDIR` changes the start point and acts as `cd` command for the image. When the container is started from that image blueprint, it will be started from where `WORKDIR` specified.
6. **In the permission listing (e.g. -rw-r--r--), what do the letters mean?**

    * This represents the Linux file access security. After the first `-`, it consists of 3 blocks of tripets.

    * **`r`**: Read

    * **`w`**: Write

    * **`x`**: Execute / Run programs

    * **`-`**: Permission Denied

    * **(`rw-`)**: The first triplets applies to the `Owner`, in this case `root`. This means that the owner can _read_ and _write_ but cannot execute.

    * **(`r--`)**: The middle set applies to `Group`. This means members of the file's assign group can only _read_ it.

    * **(`r--`)**: The last chunk applies to `Others`. Anyone else inside the container can only _read_ it.

