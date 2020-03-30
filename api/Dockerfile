# docker build . -t kvn0218/kuma-demo-be:latest
# docker push kvn0218/kuma-demo-be:latest

FROM node:lts-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3001

RUN apk add curl

CMD [ "npm", "start" ]