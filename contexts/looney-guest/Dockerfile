FROM node:16

WORKDIR /usr/src/app

ENV PUBLIC_URL="/"

RUN npm install pm2 -g

EXPOSE 3000

CMD [ "pm2", "serve", ".", "3000", "--no-daemon" ]