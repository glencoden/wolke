# ☁️ Docker cloud

## Local

### Commands

`npm start` - compose the local docker cloud
<br/>
`npm stop` - stop the local docker cloud
<br/>
`npm restart` - restart the local docker cloud, applying project changes

### Setup

Add an `.env` file at project root (example):
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

### Connect hosts

1. Edit your local hosts file with eg `sudo nano /etc/hosts`
2. Direct all your project hosts to localhost by adding lines like this `127.0.0.1 myproject.lan`
3. Flush DNS cache with `sudo killall -HUP mDNSResponder`

## Live

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
6. Add `.env.live` and `.env.prod` files at project root (they are just templates to copy to github!):
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
7. Add secrets to your github repo at `Settings > Secrets and variables > Actions`:
   <br/>
   `ENV_LIVE` - copy contents of `.env.live` file
   <br/>
   `ENV_PROD` - copy contents of `.env.prod` file
   <br/>
   `SERVER_ADDRESS_PROD` - your server IP
   <br/>
   `SSH_PRIVATE_KEY` - the private key from your machine, which you're using to connect to the server
   <br/>

Herzlichen Glückwunsch!
<br/>
Your github pipeline will deploy your docker cloud to your server every time you merge or push into `main`

### Connect hosts

1. Login to your domain provider and find the DNS setup for the domain you're using
2. Add a type A entry with your project domain as host `myproject` and your server IP as destination
3. You can spin up the cloud already, but the DNS change might take up to 48 hours, just wait

### Optional staging cloud

You can setup a copy of the project on a second server and deploy it from branch `staging`

1. Simply go through the setup steps above with another server
2. Add an `.env.staging` file at project root, with `HOST_ENV=staging` and the staging hosts for your projects, eg `staging.myproject.glencoden.io`
3. Add secrets to your github repo at `Settings > Secrets and variables > Actions`:
   <br/>
   `ENV_STAGING` - copy contents of `.env.staging` file
   <br/>
   `SERVER_ADDRESS_STAGING` - your staging server IP
   <br/>

# ☁️ Databases

⚠️ Execute scripts from project root

## Add backup git repository

To backup and restore databases, initiate a private github repository and in `scripts/backup-databases.sh` and `scripts/restore-databases.sh` replace the lines starting with `git clone git@github.com` with your backup repo url

## Init and update 

Databases are added and removed automatically when deploying live to `prod` or `staging`
<br/>
The pipeline runs `scripts/init-databases.sh` to match the list of existing postgres databases with every entry in `.env.live` starting with `POSTGRES_DATABASE_`
<br/>
<br/>
Locally, run `npm run db:init` when all docker containers are running to match the list of existing postgres databases with every entry in `.env` staring with `POSTGRES_DATABASE_`

## Backup

ssh into your server, run `crontab -e` and add the crontab line `30 0 * * * cd /root/apps/wolke && bash scripts/backup-databases.sh` to create a backup every day at 00:30h
<br/>
<br/>
Locally, `npm run db:backup` will create dump files for existing postgres databases and push them to your backup remote

## Restore

`npm run db:restore` or `bash scripts/restore-databases` with optional command line args:

`db=name` - the name of the database you wish to restore (DEFAULT restores every database)
<br/>
`env=develop` - the host environment `develop` | `staging` | `prod` you wish to retrieve the backup from (DEFAULT restores from the host env you are currently in)
<br/>
`commit=05654560fg3dd55c2c528b5134f6358bca3dc693` - the commit hash of the backup you wish to restore (DEFAULT restores most recent commit)
<br/>

# ☁️ Deploy a project

## Host environment

Any project started from a wolke context can be given access to the `HOST_ENV` variable, which values are `develop` | `staging` | `prod`
<br/>
In the related docker compose service add `HOST_ENV: ${HOST_ENV}` to the `environment` list

## Backend

⚠️ Example for node express app with typescript

Example Dockerfile `contexts/tsc/Dockerfile`
<br/>
Example cache validation script `contexts/tsc/script/validate-cache.sh` - This will make changes to a committed Dockerfile
<br/>
If you wish to use docker cache validation, see that the `sed` command in your script writes to the correct line and add the path to the script to npm script `cache:validate`

## Frontend

In your project-to-deploy remote github repository, add secrets at `Settings > Secrets and variables > Actions`:

`SERVER_ADDRESS` - IP address of target server
<br/>
`SSH_PRIVATE_KEY` - Private key from machine used for server setup

⚠️ Example for app `tsc`

In your project-to-deploy, add a github workflow at `.github/workflows/deploy-to-wolke.yml`

```yaml
on:
   push:
      branches:
         - main

jobs:
   deploy-to-wolke-prod:
      runs-on: ubuntu-latest
      steps:
         - name: check out repository
           uses: actions/checkout@v2
         - name: install node
           uses: actions/setup-node@v2
         - name: install dependencies
           run: yarn install
         - name: build app
           run: yarn build:prod
         - name: copy ssh key
           run: |
              mkdir -p ~/.ssh
              echo -e "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
              chmod 600 ~/.ssh/id_rsa
              echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
         - name: clear server directory
           run: |
              ssh root@${{ secrets.SERVER_ADDRESS_PROD }} <<"ENDSSH"
              mkdir -p /root/apps/tsc/build
              rm -rf /root/apps/tsc/build/*
              ENDSSH
         - name: deploy build
           run: |
              cd build/
              scp -r * root@${{ secrets.SERVER_ADDRESS_PROD }}:/root/apps/tsc/build
```

In your wolke project add your project-to-deploy host to `.env` | `.env.staging` | `.env.prod`

```dotenv
# Hosts
HOST_TSC=tsc.glencoden.io
```

### Static deploy

Add a Dockerfile at `contexts/my-app/Dockerfile`

```dockerfile
FROM node:16

WORKDIR /usr/src/app

ENV PUBLIC_URL="/"

RUN npm install pm2 -g

EXPOSE 3000

CMD [ "pm2", "serve", ".", "3000", "--no-daemon" ]
```

Add a service at `docker-compose.yml`

```yaml
services:
  tsc:
    build:
      context: contexts/tsc
    volumes:
      - ${STATIC_DIR}/tsc/build:/usr/src/app
    environment:
      NODE_ENV: production
      VIRTUAL_HOST: "${HOST_TSC}"
      LETSENCRYPT_HOST: "${HOST_TSC}"
    ports:
      - "3000:3000"
    container_name: tsc

```
<br/>

Restart the docker cloud locally or merge into the live branches. Provide the static build with your build command locally or by merging into `main` for live deploy. Done!