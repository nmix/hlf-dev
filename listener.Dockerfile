FROM node:8.9
LABEL maintainer="nn@mikh.pro"

RUN npm install fs node-yaml fabric-client
