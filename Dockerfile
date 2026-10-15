ARG IMAGE_TAG=latest
FROM nodered/node-red:${IMAGE_TAG}

USER root

RUN apk add --no-cache git curl

USER node-red

RUN npm install \
    node-red-contrib-cron-plus \
    kafkajs
