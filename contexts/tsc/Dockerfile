FROM node:16

WORKDIR /usr/src/app

# This is set to disable caching after this line when there are new commits (./scripts/validate-cache.sh)
ARG COMMIT_HASH=5ba5e3d197bc02ccd5f61002d7cc01556ba3fef0

RUN git clone -b develop --single-branch https://github.com/glencoden/tsc-api.git .

RUN npm install

EXPOSE 5555

CMD [ "npm", "run", "start:prod" ]