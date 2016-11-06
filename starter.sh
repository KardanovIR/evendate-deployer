#!/bin/sh

#curl -X POST --data-urlencode 'payload={"channel": "#web", "username": "webhookbot", "text":  "Docker run start", "icon_emoji": ":ghost:"}' https://hooks.slack.com/services/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

mkdir -p /usr/code/$1
rm -rf /usr/code/$1

cd /usr/docker-intances/evendate-deployer && ls

git clone -b $1 --single-branch --depth=1 https://kardanovir:kazuistika31415926@github.com/KardanovIR/evendate_web2 /usr/code/$1
docker rm -f $1
echo "docker run --privileged -d -P --name $1 -e VIRTUAL_HOST=$1.test.evendate.ru -e BRANCH_NAME=$1 -v /usr/code/$1:/var/www/html -v /usr/docker-intances/evendate-deployer:/var/www/deployer evendate_web2"
docker run --privileged -d -P --name $1 -e VIRTUAL_HOST=$1.test.evendate.ru -e BRANCH_NAME=$1 -v /usr/code/$1:/var/www/html -v /usr/docker-intances/evendate-deployer:/var/www/deployer evendate_web2