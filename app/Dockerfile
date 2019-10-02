  
FROM node:8-alpine

RUN apk update \
 && apk upgrade \
 && apk add bash curl

ADD . /kuma-demo-app-fe
WORKDIR /kuma-demo-app-fe

RUN echo Node `node --version` \
  && echo NPM `npm --version`

RUN npm install -g yarn

RUN yarn

CMD yarn serve --mode ci