FROM node:alpine

RUN apk add --no-cache certbot

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . .

RUN npm install

CMD ["node", "index"]

EXPOSE 3000
