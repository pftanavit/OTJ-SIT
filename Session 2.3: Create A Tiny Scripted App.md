# Session 2.3: Create A Tiny Scripted App

**Goal**:
* Build an Ubuntu-based image that copies a shell script into /app, makes it executable, and runs it as the container command.

**Constraints**:
* Base image must be ubuntu.
* Use a shell script.
* Use chmod.
* The script must print an environment variable.


**Expected result**:
* The image runs a script.
* The learner can pass different values with environment variables.

## Example

1. Create the `shell` script: `script.sh` on your machine.
```
#!/bin/bash

echo "Running in Docker container"
echo "my message: $MY_MESSAGE"
echo "==========================="
```

2. In the same directory as `script.sh` create s `Dockerfile`.
```
FROM ubuntu

WORKDIR /app

COPY script.sh .

RUN chmod +x script.sh

CMD ["./script.sh"]
```

3. Build the image from the `Dockerfile`.
```
docker build -t script-app .
```

4. Try starting a container from the `script-app` image.
```
docker run script-app
```

Output:
```
Running in Docker container
my message: 
===========================
```

5. Now try running with Environment Variables `-e`.
```
docker run -e MY_MESSAGE="Hello World." script-app
```
Output:
```
Running in Docker container
my message: Hello World.
===========================
```

## Questions

1. **Why did the script need execute permission?**

    * When you create a text file on your  host machine and copy it into Docker, the operating system assigns it standard read and write permissions. It treats it like a passive document, not an active program.

        Without `chmod +x`, the container's file system sees the script as: Owner (-rw-)

2. **What changed when you passed a different environment variable?**

    * The _internal memory state_ of the container changed. Changing the environment variable using `-e` does not modify a single file on the virtual hard drive. It changes the temporary environment data block when starting up a container, altering its output.


3. **Should configuration be baked into the image or passed at runtime?**

    * It should always be passed at runtime and never baked into the image. The image can be used as a blueprint for multiple purposes set at the runtime. It also ensures security without setting important information directly on to the image.
4. **The x you added is the "execute" bit. Why does a script need permission to run, not just to exist?**

    * Because without it, it is indistinguishable between a normal text file and a script. It is a security measure since if every text file is executable, it causes vulnerability to the system and could be compromised.
5. **ENV sets a default and -e overrides it. How does the shell read `$GREETING` inside the script?**

    * When the container starts up, Docker creates a localized dictionary of key-value pairs in memory called the _Environment Block_ and hands it to the shell.

        When it reaches `$GREETING`, it performs a mechanism called: **Variable Interpolation**.

        The shell stops and recognizes `$` as a pointer. It thens look up the key `GREETING` inside its local environment table. 

        If we pass `-e GREETING="Hello"`, the shell grab `Hello` and takes `$GREETING` and swap them out before the finalized line to the execution engine.  