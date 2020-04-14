# docker build . -t kvn0218/kuma-demo-fe:latest
# docker push kvn0218/kuma-demo-fe:latest

FROM node:lts-alpine

RUN npm install -g http-server 

COPY ./dist /dist

RUN apk add curl jq

EXPOSE 8080
ENTRYPOINT [ "http-server", "/dist"]
