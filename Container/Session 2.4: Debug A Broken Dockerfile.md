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
