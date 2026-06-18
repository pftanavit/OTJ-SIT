# Session 3.4: Connect Two Containers On A Network

**Goal**:
* Create two Ubuntu-based containers on the same Docker network. One container runs a simple HTTP server. The other container uses curl to reach it by container name.

**Constraints**:

* Use only base OS images or images built from base OS images.
* Do not use host port publishing for container-to-container communication.
* Use a custom Docker network.
**Expected result**:
  
* One container can reach the other by name.
