FROM node:lts-alpine

RUN npm install -g http-server @vue/cli

WORKDIR /app

COPY package*.json ./

# RUN npm install
RUN npm install

COPY . .

RUN npm rebuild node-sass

RUN npm run build

RUN apk add curl jq

EXPOSE 8080
ENTRYPOINT [ "http-server", "dist"]
