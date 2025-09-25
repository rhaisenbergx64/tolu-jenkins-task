FROM node:20.12.2-bullseye

# match Jenkins user UID/GID, e.g. 1000:1000
RUN usermod -u 1000 node && groupmod -g 1000 node

USER node
WORKDIR /home/node/app