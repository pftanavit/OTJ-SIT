## Session 1.2: Container Lifetime And State 

**Goal:** Create a file inside a container, exit, find the stopped container, start it again, and prove whether the file still exists. then recreate the container and see what happens to the file.

**Constraints:**

- Use only Ubuntu.  
- Do not use volumes.  
- Do not create a Dockerfile.

You must explain the difference between stopping and removing a container.

**Expected result:**

- The learner can find stopped containers.  
- The learner can restart a stopped container.  
- The learner understands when container state survives and when it disappears.

**States:**

![][image1]

- **docker ps \-a:** shows all the containers with all the statuses.  
- **docker ps:** shows only the containers that are up and running currently.  
- **docker run:** create a brand new container.  
- **docker start \-i \<container\_id\>:** start the stopped container with that container\_id.  
- **docker rm \<container\_id\>:** remove and delete the container.

## Questions:

**Q: What survives after docker stop?**

**Answer:** *Everything on the disk survives. The writable layer remains completely intact and preserved. It is stored and waiting to be started back on.*

**Q: What disappears after docker rm?**

**Answer:** *Everything disappears, the configurations, the settings, the history. Anything inside that container is completely wiped.* 

**Q: Why should important data not live only inside a disposable container?**

**Answer:** *Containers are designed to be stateless and disposable. Therefore, entrusting important data on it induces risks such as accidental deletion and accessing it on other applications is also more difficult. Important data can also be at risk when software updates happen on a container.*

**Q: After docker start, docker exec back in and run ls. Is your file still there?**

**Answer:** *Yes, it would still be there because it loaded up an existing container. Running ls will show that your files are still there.*

**Q: Run ps. How many processes do you see running inside the container?**

**Answer:** *2\. PID 1 (bash) and PID 8 (ps). PID 1 is the primary process. It is the interactive shell that runs with docker run \-it. PID 8 is the tool run with the ps command.* 

**Q: What is the difference between the states paused and stopped.**

**Answer:** *Paused means the container process is frozen and can be resumed. Stopped means the main process has exited or has been stopped. Both are different from removed, where the container object is deleted.*

## Examples:
**1. Create a new container and create a new file inside.**
```
docker run -it ubuntu
```
Inside the container:
```
echo "hello docker" > test.txt
ls
cat test.txt
exit
```
Output:
```
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  test.txt  tmp  usr  var

hello docker
```
**2. Find the stopped container.**

```
docker ps -a
```
Output:
```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         NAMES
6171afcbb1b8   ubuntu         "/bin/bash"              2 minutes ago   Exited (0) 4 seconds ago             vibrant_robinson
```

**3. Start the same container again.**
```
docker start -i 6171afcbb1b8
cat test.txt
exit
```
Output:
```
hello docker
```
This proves that stopping the container did not remove its writable layer.

**4. Removing the container and creating a brand new one.**

```
docker rm 6171afcbb1b8
docker run -it ubuntu
```
Inside the new container:
```
ls
exit
```
Output:
```
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```
This proves that a newly created container does not inherit files from the removed container.

## Conclusion

`docker stop`: Shuts down the active processes, but freezes the container and its writable layer on the disk.

`docker start`: Wakes up that exact same container. The files survive because you are jumping back into the same writable layer.

`docker rm`: Destroys the container object and its writable layer completely. The base Ubuntu image stays safe, but the unique files are gone forever.

`docker run`: Creates a brand-new container from scratch with a completely blank writable layer.

[image1]: https://github.com/user-attachments/assets/5a671db1-d1a3-4869-9aab-eb6590968d4b
