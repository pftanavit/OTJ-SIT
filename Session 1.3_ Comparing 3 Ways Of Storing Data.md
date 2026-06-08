## Session 1.3_ Comparing 3 Ways Of Storing Data

### Comparing 3 methods:

1. File inside container writable layer.
2. File through bind mount.
3. File through named volume.


****

**1. Container Writable Layer**

Start up a new container.
```
docker run -it --name test-disposible ubuntu
echo "temporary" > disposible.txt
exit
```
Delete the container.
```
docker rm test-disposible
```
Try to find the file on a new container
```
docker run -it --name new-disposible ubuntu
ls
exit
```
Output:
```
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```
The data is stored inside the container's writable layer. When the container is deleted, it is gone.

**2. Bind Mount**

Create a folder and store a file there.
```
mkdir -p ~/host-data
```
Create a new container bind to a folder inside:
```
docker run -it --name test-mount -v ~/host-data:/data ubuntu
echo "Created inside container" > data/container.txt
exit
```
Delete the container.
```
docker rm test-mount
```
Look inside the folder.
```
cat host-data/container.txt
```
Output:
```
Created inside container
```
If you look at the `host-data` folder, the file `container.txt` that was created still exists even when the container was deleted.

**3. Named Volume**

Create a named volume.
```
docker volume create state-demo
```
Attach the volume to container1 at `/data`.

```
docker run -it --name container1 -v state-demo:/data ubuntu
```
Write a file inside container1 then destroy the container.
```
echo "Created inside container1" > data/data.txt
exit
docker rm container1
```
Create a new container `container2` at the same volume.
```
docker run -it --name container2 -v state-demo:/data ubuntu
```
Check the directory:
```
cat data/data.txt
exit
```
Output:
```
Created inside container1
```

Even though the original container `container1` was deleted, `container2` still inherited the data from `state-demo` volume.

## Conclusion

**Container Writable Layer:** The data is stored inside the container's private temporary file system. If the container is deleted, the file is also deleted.

**Bind Mount:** Data is stored at a specific path on the host machine. Even if the container is deleted, the file is still on the host machine.

**Named Volume:** The data is stored in a secure storage system completely managed by Docker. Named volumes isolate storage from the host's direct configuration, making them highly portable, easy to share across multiple containers

_A container writable layer is temporary and tied to one container, while bind mounts and named volumes are better choices for data that must survive container removal._
