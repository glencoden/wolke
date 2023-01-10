# Stage one to build app
FROM node:16

# This is set to disable caching after this line when there are new commits (./scripts/validate-cache.sh)
ARG COMMIT_HASH=e8cea76323347307509ca533d20ea20ba40f476e

WORKDIR /usr/src/app

RUN git clone -b main --single-branch https://github.com/glencoden/berta-bot.git .
RUN npm install

EXPOSE 5555

CMD [ "node", "index.js" ]