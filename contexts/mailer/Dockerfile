# Stage one to build app
FROM node:16

# This is set to disable caching after this line when there are new commits (./scripts/validate-cache.sh)
ARG COMMIT_HASH=a1f88591ba3e6e4ad5f89cd2d81d1c91c69bc7b9

WORKDIR /usr/src/app

RUN git clone -b main --single-branch https://github.com/glencoden/mailer.git .
RUN npm install

EXPOSE 5555

CMD [ "node", "index.js" ]