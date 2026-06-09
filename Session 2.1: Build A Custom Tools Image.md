## Session 2.1: Build A Custom Tools Image
**Goal:**
- Create a Dockerfile from ubuntu that installs curl and runs curl --version by default.

**Constraints:**
- Base image must be ubuntu.
- Use a Dockerfile.
- The final image must run without manually entering the container.
**Expected result:**
- docker build creates a custom image.
- docker run executes the default command.
