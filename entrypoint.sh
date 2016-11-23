#!/bin/bash

echo "starting"
echo $BRANCH_NAME
php /var/www/deployer/init.php $BRANCH_NAME


service postgresql restart

mkdir -p /var/www/deployer/
touch /var/www/deployer/pg_dump_logs.log

pg_dump --host evendate.ru --port 5432 --username "postgres" --role "postgres" --no-password --format tar --encoding UTF8 --exclude-table-data=log_requests --verbose --file /var/www/deployer/db_dump.backup "evendate"
PGPASSWORD="APASSWORD" pg_restore --host localhost --port 5432 --username "postgres" --role "postgres" --no-password --dbname=evendate --verbose /var/www/deployer/db_dump.backup

PGPASSWORD="APASSWORD" psql --host localhost --port 5432 --username "postgres" -d evendate  --no-password -a --file=`find . -path "/usr/code/$BRANCH_NAME/migrations/*$BRANCH_NAME-up*"`


#cd /var/www/deployer && npm install
#node db_dumper.js

service apache2 restart
cd /var/www/html/node && npm install
ENV=test forever start server.js

curl -X POST --data-urlencode 'payload={"channel": "#web", "username": "webhookbot", "text":  "Docker run done", "icon_emoji": ":ghost:"}' https://hooks.slack.com/services/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

tail -f /dev/null