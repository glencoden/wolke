# Stage one to build app
FROM node:16

# This is set to disable caching after this line when there are new commits (./scripts/validate-cache.sh)
ARG COMMIT_HASH=e248b081d2dd0ac9b9386ec8a246f7f84c6a5de2

WORKDIR /usr/src/app

RUN git clone -b main --single-branch https://github.com/glencoden/berta-bot.git .
RUN npm install

EXPOSE 5555

CMD [ "node", "index.js" ]