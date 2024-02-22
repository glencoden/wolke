# Stage one - build the app
FROM rust:1.76 as rustbuilder

# This is set to disable caching after this line when there are new commits (./scripts/validate-cache.sh)
ARG COMMIT_HASH=a8b79f65b6d5f53c848530a893f1cd090945798f

ARG DATABASE_URL
ARG UUID

RUN apt-get update && apt-get install -y git

WORKDIR /usr/src

RUN git clone -b main --single-branch https://github.com/glencoden/cards-backend.git .

RUN cargo --config ${DATABASE_URL}
RUN cargo --config ${UUID}

RUN cargo build --release

# Stage two - generate tailwind css
FROM node:18 as nodebuilder

WORKDIR /usr/src

COPY --from=rustbuilder /usr/src .

RUN npm install --production=false && npm run tailwind:build

# Stage three - run the app
FROM debian:bookworm-slim

ARG DATABASE_URL
ARG UUID

ENV DATABASE_URL=${DATABASE_URL}
ENV UUID=${UUID}

RUN apt-get update && apt-get install -y openssl ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=rustbuilder /usr/src/target/release/cards-backend .
COPY --from=nodebuilder /usr/src/assets /assets

CMD ["./cards-backend"]
