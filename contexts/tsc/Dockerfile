FROM node:16

WORKDIR /usr/src/app

# This is set to disable caching after this line when there are new commits (./scripts/validate-cache.sh)
ARG COMMIT_HASH=c19a6ab591bc2e6d11cee33b87ae98b04dd2f461

RUN git clone -b develop --single-branch https://github.com/glencoden/tsc-api.git .

RUN npm install

EXPOSE 5555

CMD [ "npm", "run", "start:dist" ]