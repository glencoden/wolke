# docker cloud

### databases

npm run restore db=my-service env=develop commit=05657560fa3dd55c2c528b5134f6358bca3dc693

# New projects

## Backend

## Frontend

### Static deploy

ON WOLKE - add context and service

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

```

ON PROJECT GITHUB - add repository secrets

`SERVER_ADDRESS`: IP address of target server
<br/>
`SSH_PRIVATE_KEY`: Private key from machine used for server setup

IN PROJECT - add github workflow

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