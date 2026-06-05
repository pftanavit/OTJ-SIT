**Session 1.2: Container Lifetime And State**

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

**Questions:**

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

**Answer:** *When paused, the process is frozen. The CPU stops but the RAM stays full. Stopping fully kills the container while pausing freezes it in place. Pausing and unpausing takes a shorter time since the container does not need to boot up again. Docker start takes longer.*

[image1]: https://github.com/user-attachments/assets/5a671db1-d1a3-4869-9aab-eb6590968d4b
