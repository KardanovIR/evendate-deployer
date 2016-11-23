var fs = require('fs'),
    exec = require('child_process').exec,
    args,
    config = JSON.parse(fs.readFileSync('./config.json')),
    app_config = JSON.parse(fs.readFileSync('/var/www/html/v1-config.json')).test.db,
    pg_conn_string = [
        'postgres://',
        config.user,
        ':', config.password,
        '@', config.host,
        ':', config.port,
        '/', config.database
    ].join(''),
    pg_local_conn_string = [
        'postgres://',
        app_config.user,
        ':', app_config.password,
        '@', app_config.host,
        ':', app_config.port,
        '/', app_config.database
    ].join('');
console.log(app_config);

pg.connect(pg_local_conn_string, function (err, local_client, done) {
    local_client.query('SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema=\'public\' ORDER BY table_schema,table_name;', function (local_err, local_result) {
        if (local_err) console.log(local_err);
        local_result.rows.forEach(function (row) {
            console.log(row.table_name);
        });
    });
});