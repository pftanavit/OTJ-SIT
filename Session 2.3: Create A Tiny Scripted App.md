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