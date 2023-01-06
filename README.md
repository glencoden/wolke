# ☁️ Docker cloud setup

## * Local *

### Commands

`npm start` - compose the local docker cloud
<br/>
`npm stop` - stop local docker cloud
<br/>
`npm restart` - restart local docker cloud, applying changes in the project

### Setup

Add and `.env` file at project root. Example:
```dotenv
# LetsEncrypt! SSL
SSL_EMAIL=example@glencoden.io

# Postgres database
POSTGRES_USER=glencoden
POSTGRES_PASSWORD="test1234"

# Database names
POSTGRES_DATABASE_MY_PROJECT=my_project

# Admin (this wil only be needed when for example a BE project creates an initial admin with an auth db)
ADMIN_USERNAME=glencoden
ADMIN_PASSWORD="admin1234"

# Misc
STATIC_DIR=.. # This is where the static builds of the projects you host in this cloud are

# Hosts env specific vars
# For live, add this to .env.staging and .env.prod

HOST_ENV=develop

# Hosts
HOST_MY_PROJECT=myproject.lan
```

### Connect hosts of projects you deploy with this cloud to localhost

1. Edit your local hosts file with eg `sudo nano /etc/hosts`
2. Direct all your project hosts to localhost by adding lines like this `127.0.0.1 myproject.lan`
3. Flush DNS cache with `sudo killall -HUP mDNSResponder`

## * Live *

### Setup

1. Find a server with a linux distro
2. Install docker and git
3. Configure git:
```shell
git config --global user.email "bot@glencoden.io"
git config --global user.name "glen coden"
```
4. Generate ssh key pair:
```shell
ssh-keygen -t rsa -b 4096 -C my-server-name
```
5. Add public key to your github general setup ssh keys
6. Add `.env.live` and `.env.prod` files at project root (these are just templates to copy to github!):
```dotenv
# .env.live
# Environment vars shared by all live deploys of this cloud

# LetsEncrypt! SSL
SSL_EMAIL=example@glencoden.io

# Postgres database
POSTGRES_USER=glencoden
POSTGRES_PASSWORD="test1234"

# Database names
POSTGRES_DATABASE_MY_PROJECT=my_project

# Admin (this wil only be needed when for example a BE project creates an initial admin with an auth db)
ADMIN_USERNAME=glencoden
ADMIN_PASSWORD="admin1234"

# Misc
STATIC_DIR=.. # This is where the static builds of the projects you want to host in this cloud are

# Hosts env specific vars will be appended in deploy pipeline
```
```dotenv
# .env.prod
# Development stage specific environment vars

HOST_ENV=prod

# Hosts
HOST_MY_PROJECT=myproject.glencoden.io
```
7. Add secrets to your github repo at `Settings/Secrets/Actions/`:
<br/>
`ENV_LIVE` - copy contents of `.env.live` file
<br/>
`ENV_PROD` - copy contents of `.env.prod` file
<br/>
`SERVER_ADDRESS_PROD` - your server IP
<br/>
`SSH_PRIVATE_KEY` - the private key from your machine, which you're using to connect to the server

Herzlichen Glückwunsch!
<br/>
Your github pipeline will deploy your docker cloud to your server every time you merge or push into `main`!

### Connect hosts of projects you deploy with this cloud to your server IP

1. Login to your domain provider and find the DNS setup for the domain you're using
2. Add a type A entry with your project domain as host `myproject` and your server IP as destination
3. You can spin up the cloud already, but the DNS change might take up to 48 hours, just wait

### Optional staging cloud

You can setup a copy of the project on a second server and deploy it from branch `staging`.

1. Simply go through the setup steps above with another server
2. Add an `.env.staging` file at project root, with `HOST_ENV=staging` and the staging hosts for your projects, eg `staging.myproject.glencoden.io`
3. Add secrets to your github repo at `Settings/Secrets/Actions/`:
   <br/>
   `ENV_STAGING` - copy contents of `.env.staging` file
   <br/>
   `SERVER_ADDRESS_STAGING` - your staging server IP

# ☁️ Databases

LOCAL
npm run db:restore db=name env=develop commit=05657560fa3dd55c2c528b5134f6358bca3dc693

SERVER
cd to project root!

INIT
BACKUP bash scripts/backup-databases.sh
RESTORE bash scripts/restore-databases.sh db=name env=develop commit=05657560fa3dd55c2c528b5134f6358bca3dc693

## Cron

# ☁️ Deploy a project

## Backend

## Frontend

<br/>

### Static deploy

<br/>

IN PROJECT GITHUB add repository secrets

`SERVER_ADDRESS`: IP address of target server
<br/>
`SSH_PRIVATE_KEY`: Private key from machine used for server setup

<br/>

IN PROJECT add github workflow

Workflow example `.github/workflows/deploy-to-wolke.yml`

```yaml
on:
  push:
    branches:
      - main

jobs:
  deploy-to-wolke:
    runs-on: ubuntu-latest
    steps:
      - name: check out repository
        uses: actions/checkout@v2
      - name: install node
        uses: actions/setup-node@v2
      - name: install dependencies
        run: yarn install
      - name: build app
        run: yarn build
      - name: copy ssh key
        run: |
          mkdir -p ~/.ssh
          echo -e "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
      - name: clear server directory
        run: |
          ssh root@${{ secrets.SERVER_ADDRESS }} <<"ENDSSH"
          rm -rf /root/apps/tsc/*
          mkdir -p /root/apps/tsc/
          ENDSSH
      - name: deploy build
        run: |
          cd build/
          scp -r * root@${{ secrets.SERVER_ADDRESS }}:/root/apps/tsc/
```

<br/>

IN WOLKE add env vars, context and service

Host environment variable example `.env` | `.env.staging` | `.env.prod`

```dotenv
# Hosts
HOST_TSC=tsc.glencoden.io
```

Make sure `STATIC_DIR` points to where your app is `.env` | `.env.live`

```dotenv
STATIC_DIR=..
```

Dockerfile example `contexts/my-app/Dockerfile`

```dockerfile
FROM node:16

WORKDIR /usr/src/app

ENV PUBLIC_URL="/"

RUN npm install pm2 -g

EXPOSE 3000

CMD [ "pm2", "serve", ".", "3000", "--no-daemon" ]
```

Service example `docker-compose.yml`

```yaml
services:
  tsc:
    build:
      context: contexts/tsc
    volumes:
      - ${STATIC_DIR}/tsc/${BUILD_DIR}:/usr/src/app
    environment:
      NODE_ENV: production
      VIRTUAL_HOST: "${HOST_TSC}"
      LETSENCRYPT_HOST: "${HOST_TSC}"
    ports:
      - "3000:3000"
    container_name: tsc

```

<br/>