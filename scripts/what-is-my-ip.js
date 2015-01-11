var casper = require('casper').create({
    pageSettings: {
        userAgent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36',
        loadImages: false,
        loadPlugins: false
    }
});

casper.options.waitTimeout = casper.cli.get('timeout');

casper.start('http://mxtoolbox.com/WhatIsMyIP/', function() {
    var id = 'ctl00_ContentPlaceHolder1_hlIP';
    this.waitForSelector('#' + id, function () {
        this.echo('My IP address is : '+ this.evaluate(function (id) {
            return document.getElementById(id).innerHTML;
        }, id));

        this.exit(0);
    });
});

casper.run();
