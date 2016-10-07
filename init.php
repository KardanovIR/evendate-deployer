<?php
/*change postgres settings*/

$postgres_conf = '/etc/postgresql/9.5/main/postgresql.conf';
$pg_hba_conf = '/etc/postgresql/9.5/main/pg_hba.conf';

$data = file_get_contents($pg_hba_conf);
$data = str_replace("127.0.0.1/32            md5",
	"0.0.0.0/0            trust",
	$data);
$result = file_put_contents($pg_hba_conf, $data);
echo "Postgres HBA updated:" . $result;

$data = file_get_contents($postgres_conf);
$data = str_replace("#listen_addresses = 'localhost'", "listen_addresses = '*'", $data);
$result = file_put_contents($postgres_conf, $data);
echo "Postgres confifurations updated" . $result;



exec ("sudo service postgresql restart");

/*change php settings*/

$php_ini = '/etc/php/7.0/apache2/php.ini';
$data = file_get_contents($php_ini);
$data = str_replace("error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT", "error_reporting = E_ALL", $data);
$data = str_replace("display_errors = Off", "display_errors = On", $data);
$data = str_replace(";extension=php_mbstring.dll", "extension=php_mbstring.so", $data);
$data = str_replace(";extension=php_pdo_mysql.dll", "extension=php_pdo_mysql.so", $data);
$data = str_replace(";extension=php_pdo_pgsql.dll", "extension=php_pdo_pgsql.so\nextension=mongodb.so", $data);
$data = str_replace("session.gc_maxlifetime = 1440", "session.gc_maxlifetime = 2592000", $data);
$data .= "[xdebug] \n
		zend_extension = /usr/lib/php/20151012/xdebug.so \n
		xdebug.remote_enable = 1 \n
		xdebug.remote_host = 10.0.2.2 \n
		xdebug.remote_port = 9000 \n";

file_put_contents($php_ini, $data);

echo "PHP configurations updated";

/*change mongodb settings*/
