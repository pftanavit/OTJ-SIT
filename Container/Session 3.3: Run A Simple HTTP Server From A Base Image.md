# Session 3.3: Run A Simple HTTP Server From A Base Image

**Goal**:

* Use an Ubuntu-based Dockerfile to install a small HTTP server tool and serve a file from `/app/public` on a host port.

**Constraints**:

* Base image must be ubuntu.
* Do not use the nginx, httpd, node, or python base image.
* Install the required package yourself.
* Publish the container port to the host.

**Expected result**:
* A browser or curl on the host can reach the file served by the container.
