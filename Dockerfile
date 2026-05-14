FROM nodered/node-red:latest

USER root

RUN apk add --no-cache git curl

USER node-red

RUN npm install \
    node-red-contrib-cron-plus \
    kafkajs
