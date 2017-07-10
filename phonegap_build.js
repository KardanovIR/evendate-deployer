var client = require('phonegap-build-api');

client.auth({ username: 'kardinal3094@gmail.com', password: 'Aues300694$$$' }, function(e, api) {
    api.post('/apps/1558920/build/ios', function(e, data) {
        console.log('error:', e);
        console.log('data:', data);
    });

});
