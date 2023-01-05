FROM node:16

WORKDIR /usr/src/app

# This is set to disable caching after this line when there are new commits (./scripts/validate-cache.sh)
ARG COMMIT_HASH=88c674b84ea983a4fa3c3038276f4badd7a0d2e2

RUN git clone -b develop --single-branch https://github.com/glencoden/tsc-api.git .

RUN npm install

EXPOSE 5555

CMD [ "npm", "run", "start:dist" ]