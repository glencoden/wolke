# Stage one to build app
FROM node:16

# This is set to disable caching after this line when there are new commits (./scripts/validate-cache.sh)
ARG COMMIT_HASH=f068459a2a4b058d9eff1edfdeaa0c2311745c27

WORKDIR /usr/src/app

RUN git clone -b main --single-branch https://github.com/glencoden/looney-api.git .
RUN npm install
RUN npm install -g typescript@^4.5.5
RUN tsc -b

# Stage two to run app
FROM node:16

WORKDIR /usr/src/app

COPY --from=0 /usr/src/app/package.json .
RUN npm install --only=production
COPY --from=0 /usr/src/app/dist .

EXPOSE 5555

CMD [ "node", "index.js" ]