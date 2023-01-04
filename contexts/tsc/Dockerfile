FROM node:16

WORKDIR /usr/src/app

# This is set to disable caching after this line when there are new commits (./scripts/validate-cache.sh)
ARG COMMIT_HASH=88429be79eb4536ff30a61c956c262c7555defe3

RUN git clone -b develop --single-branch https://github.com/glencoden/tsc-api.git .

RUN npm install

EXPOSE 5555

CMD [ "npm", "run", "start:dist" ]