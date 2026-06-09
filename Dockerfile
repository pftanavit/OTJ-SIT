FROM ubuntu

RUN apt-get update && apt-get install curl

CMD ["curl", "--version"]
