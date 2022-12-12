FROM node:16

WORKDIR /usr/src/app

RUN npm install pm2 -g

EXPOSE 3200
CMD [ "pm2", "serve", ".", "3200", "--no-daemon" ]