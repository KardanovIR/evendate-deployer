<?php
/*change postgres settings*/

$postgres_conf = '/etc/postgresql/9.6/main/postgresql.conf';
$pg_hba_conf = '/etc/postgresql/9.6/main/pg_hba.conf';

$data = file_get_contents($pg_hba_conf);
$data = str_replace("127.0.0.1/32            md5",
	"0.0.0.0/0            trust",
	$data);
$result = file_put_contents($pg_hba_conf, $data);
echo "Postgres HBA updated:" . $result;

$data = file_get_contents($postgres_conf);
$data = str_replace("#listen_addresses = 'localhost'", "listen_addresses = '*'", $data);
$result = file_put_contents($postgres_conf, $data);
echo "Postgres confifurations updated\n";

exec ("service postgresql restart");

/*change php settings*/

$php_ini = '/etc/php/7.0/apache2/php.ini';
$data = file_get_contents($php_ini);
$data = str_replace("error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT", "error_reporting = E_ALL", $data);
$data = str_replace("display_errors = Off", "display_errors = On", $data);
$data = str_replace(";extension=php_mbstring.dll", "extension=php_mbstring.so", $data);
//$data = str_replace(";extension=php_pdo_mysql.dll", "extension=php_pdo_mysql.so", $data);
$data = str_replace(";extension=php_pdo_pgsql.dll", "extension=php_pdo_pgsql.so", $data);
$data = str_replace("session.gc_maxlifetime = 1440", "session.gc_maxlifetime = 2592000", $data);

file_put_contents($php_ini, $data);

echo "\nPHP configurations updated";

//TODO: Сделать получение тестовой ветки
$branch_name = $argv[1];

$htaccess = '/var/www/html/.htaccess';
$data = file_get_contents($htaccess);
$data = str_replace('Header add Access-Control-Allow-Origin "*"',
	"Header add Access-Control-Allow-Origin \"http://{$branch_name}.test.evendate.ru\" \n 
	Header add Access-Control-Allow-Credentials \"true\" \n 
	php_value upload_max_filesize 100M \n
	php_value post_max_size 100M
	", $data);

$data .= "\nSetEnv ENV \"test\" 
\nSetEnv TEST_DOMAIN \"{$branch_name}\"
\nRewriteEngine On
\nRewriteCond %{REQUEST_URI}  ^/socket.io            [NC]
\nRewriteCond %{QUERY_STRING} transport=websocket    [NC]
\nRewriteRule /(.*)           ws://localhost:8080/$1 [P,L]";

file_put_contents($htaccess, $data);

echo "\n htaccess updated";


$config = '/var/www/html/v1-config.json';
$data = file_get_contents($config);
$data = str_replace('"domain": "test.evendate.ru",', "\"domain\": \"{$branch_name}.test.evendate.ru\",", $data);
$data = str_replace('"node_domain": "test.evendate.ru",', "\"node_domain\": \"{$branch_name}.test.evendate.ru\",", $data);

file_put_contents($config, $data);

echo "\n config updated";

$config = '/var/www/html/app/js/app.js';
$data = file_get_contents($config);
$data = str_replace('"domain": "test.evendate.ru",', "\"domain\": \"{$branch_name}.test.evendate.ru\",", $data);
$data = str_replace('"node_domain": "test.evendate.ru",', "\"node_domain\": \"{$branch_name}.test.evendate.ru\",", $data);

file_put_contents($config, $data);

echo "\n config updated";
