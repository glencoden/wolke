FROM node:16

WORKDIR /usr/src/app

# This is set in scripts/set-cache-time.sh before docker compose, to disable caching after this line
ARG CACHE_TIME=1671141691

RUN git clone -b develop --single-branch https://github.com/glencoden/tsc-api.git .

RUN npm install

EXPOSE 5555

CMD [ "npm", "run", "start:prod" ]