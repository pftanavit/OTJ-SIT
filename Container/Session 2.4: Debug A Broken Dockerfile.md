# Session 2.4: Debug A Broken Dockerfile

## Goal

* Fix a broken Dockerfile that fails because of wrong paths, missing permissions, or wrong command format.

## Constraints

* Base image must be ubuntu.
* Do not replace the whole Dockerfile at once.
* Explain each fix.

## Expected result

* The image builds successfully.
* The container runs successfully.
* The learner can explain why it failed before.

```
FROM ubuntu:24.04

WORKDIR /app

COPY start.sh /scripts/start.sh

RUN chmod +x start.sh

CMD ["start.sh"]
```

## Example

1. Examine the given code and try running it.

    ```
        FROM ubuntu:24.04

        WORKDIR /app

        COPY start.sh /scripts/start.sh

        RUN chmod +x start.sh

        CMD ["start.sh"]
    
    ```
    Output:
    ```
       Dockerfile:7
        --------------------
        5 |     COPY start.sh /scripts/start.sh
        6 |     
        7 | >>> RUN chmod +x start.sh
        8 |     
        9 |     CMD ["start.sh"]
        --------------------
        ERROR: failed to build: failed to solve: process "/bin/sh -c chmod +x start.sh" did not complete successfully: exit code: 1
 
    ```
    The code failed. After closely examining it, notice `WORKDIR` redirected to `/app`. However, `COPY` copied `start.sh` into `/scripts/start.sh`. So, when `RUN`, it cannot find `start.sh` since it is in `/script` but right now we are looking inside `/app`.

    **Fix #1**: Change from `/scripts/start.sh` to `/app/start.sh`

    ```
        FROM ubuntu:24.04

        WORKDIR /app

        COPY start.sh .

        RUN chmod +x start.sh

        CMD ["start.sh"]
    ```
    Output:
    ```
    [+] Building 1.9s (9/9) FINISHED
    ```

2. Try starting a container now.

    ```
    docker run attempt
    ```
    Output:
    ```
        What's next:
        Debug this container error with Gordon → docker ai "help me fix this container error"
        docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: exec: "start.sh": executable file not found in $PATH
    ```
    What happened. During `CMD ["start.sh"]`, it failed to execute. When using `CMD`, Docker bypasses the Linux shell and tries to invoke the command directly. The operating system looks at `start.sh` and assumes it is a global system command and look for it in `$PATH`, however, `start.sh` lives in `/app` so it failed to find it and crashes.

    **Fix #2**: Adjust `CMD ["start.sh"]`

    ```
    FROM ubuntu:24.04

    WORKDIR /app

    COPY start.sh .

    RUN chmod +x start.sh

    CMD ["./start.sh"]
    ```
    The `./` tells the operating system to look directly in the current working directory.
    Rebuild the image and try starting a container again.

    **_Container now works perfectly and can execute the script as intended._**
