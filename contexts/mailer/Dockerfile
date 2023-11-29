# Stage one to build app
FROM node:16

# This is set to disable caching after this line when there are new commits (./scripts/validate-cache.sh)
ARG COMMIT_HASH=152344ccb436ee0bddb3ca0d8004eb3c0dc354f2

WORKDIR /usr/src/app

RUN git clone -b main --single-branch https://github.com/glencoden/mailer.git .
RUN npm install

EXPOSE 5555

CMD [ "node", "index.js" ]