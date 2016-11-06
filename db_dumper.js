var util = require('util'),
    spawn = require('child_process').spawn,
    pg = require('pg'),
    sys = require('sys'),
    fs = require('fs'),
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

        setTimeout(function(){
            pg.connect(pg_conn_string, function (err, client, done) {
                client.query('SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema=\'public\' ORDER BY table_schema,table_name;', function (err, result) {
                    args = [
                        '--host',
                        'evendate.ru',
                        '--port',
                        '5432',
                        '--username',
                        'postgres',
                        '--role',
                        'postgres',
                        '--no-password',
                        '--format',
                        'tar',
                        '--encoding',
                        'UTF8',
                        '--file',
                        '/var/www/deployer/data_dump.backup'
                    ];
                    result.rows.forEach(function (row) {
                        if (config.exclude_tables.indexOf(row.table_name) == -1) {
                            args.push('--table');
                            args.push(row.table_schema + '.' + row.table_name);
                        }
                    });
                    args.push('evendate');
                    var ls = spawn('pg_dump', args);

                    console.log(args.join(' '));

                    ls.stdout.on('data', function (data) {    // register one or more handlers
                        console.log('stdout: ' + data);
                    });

                    ls.stderr.on('data', function (data) {
                        console.log('stderr: ' + data);
                    });

                    ls.on('exit', function (code) {
                        console.log('Dumping is over: ' + code);

                        var local_args = [
                            '--host',
                            'localhost',
                            '--port',
                            '5432',
                            '--username',
                            'postgres',
                            '--role',
                            'postgres',
                            '--no-password',
                            '--verbose',
                            '/var/www/deployer/data_dump.backup'
                        ];

                        var ls2 = spawn('pg_restore', local_args);
                        console.log(local_args.join(' '));

                        ls2.stdout.on('data', function (data) {    // register one or more handlers
                            console.log('stdout: ' + data);
                        });

                        ls2.stderr.on('data', function (data) {
                            console.log('stderr: ' + data);
                        });

                        ls.on('exit', function (code) {
                            console.log('Restoring is over: ' + code);
                            var child = exec('curl -X POST --data-urlencode \'payload={"channel": "#web", "username": "webhookbot", "text":  Docker run done with code: "' + code + '", "icon_emoji": ":ghost:"}\' https://hooks.slack.com/services/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', function (error, stdout, stderr) {
                                sys.print('stdout: ' + stdout);
                                sys.print('stderr: ' + stderr);
                                if (error !== null) {
                                    console.log('exec error: ' + error);
                                }
                            });
                            process.exit(code);
                        });
                    });

                })
            });
        }, 100000);
    });
});