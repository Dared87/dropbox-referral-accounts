"use strict";

var casper = require('casper').create({
        verbose: true,
        logLevel: 'debug',
        waitTimeout: 20000
    }),
    account,
    action,
    actions,
    accountId,
    emailFormat,
    dropboxUrl;

if ( ! casper.cli.has(3)) {
    console.log('Usage: manage-account.js <action> <account_id> <emailFormat> <dropboxUrl>');
    casper.exit(1);
}

action = casper.cli.get(0);
accountId = casper.cli.get(1);
emailFormat = casper.cli.get(2);
dropboxUrl = casper.cli.get(3);

if (action !== 'link' && action !== 'create') {
    console.log('The action must be either "link" or "create".');
    casper.exit(1);
}
if (emailFormat.indexOf('%s') < 1) {
    console.log('The email format MUST contain "%s" so it can be replaced by the account ID.');
}

account = {
    firstName: 'John',
    lastName: 'Doe',
    password: '123123',
    email: emailFormat.replace(/%s/, accountId)
};

casper.options.onWaitTimeout = function () {
    this.waitUntilVisible(
        '.error-message',
        function () {
            this.log(this.evaluate(function () { return jQuery('.error-message').text(); }), 'error');
            safeExit(this, 1);
        },
        function () {
            safeExit(this, 1);
        }
    );
};

actions = {
    create: function () {
        this.waitForSelector(
            'html.js',
            function () {
                var form = 'form[action="/ajax_register"] ',
                    formField = form +'input',
                    formButton = form +'button.login-button';

                this.sendKeys(formField +'[name="fname"]', account.firstName);
                this.sendKeys(formField +'[name="lname"]', account.lastName);
                this.sendKeys(formField +'[name="email"]', account.email);
                this.sendKeys(formField +'[name="password"]', account.password);

                var termsAndConditionsIsChecked = this.evaluate(function (formField) {
                    return jQuery(formField +'[name="tos_agree"]:checked').length === 1;
                }, formField);

                if ( ! termsAndConditionsIsChecked) {
                    this.click('input[name="tos_agree"]');
                }

                this.wait(2000, function () {
                    this.click(formButton);
                });
            }
        );

        var selector = '//*[@id="header-account-menu"]/a',
            text = account.firstName +' '+ account.lastName;

        this.waitUntilVisible(
            {
                type: 'xpath',
                path: selector + '[contains(., "' + text + '")]'
            },
            function () {
                this.log('Account created successfully !', 'info');
                safeExit(this, 0);
            }
        );
    },
    link: function () {
        this.waitForSelector(
            'html.js',
            function () {
                var form = 'form[action="/cli_link_nonce"] ',
                    formField = form +'input',
                    formButton = form +'button.login-button';

                this.sendKeys(formField +'[name="login_email"]', account.email);
                this.sendKeys(formField +'[name="login_password"]', account.password);

                var rememberMeIsChecked = this.evaluate(function (formField) {
                    return jQuery(formField +'[name="remember_me"]:checked').length === 1;
                }, formField);

                if (rememberMeIsChecked) {
                    this.click(formField +'[name="remember_me"]');
                }

                this.wait(2000, function () {
                    this.click(formButton);
                });
            }
        );

        var selector = '//*[@id="page-content"]/div/div[2]/p[1]',
            text = 'Your computer was successfully linked to your account';

        this.waitUntilVisible(
            {
                type: 'xpath',
                path: selector + '[contains(., "' + text + '")]'
            },
            function () {
                this.log('Account was linked successfully !', 'info');
                safeExit(this, 0);
            }
        );
    }
};

casper.start(dropboxUrl);
casper.then(actions[action]);
casper.run();

function safeExit(casper, code)
{
    casper.capture('screenshots/exit_'+ code +'_'+ Math.random() +'.png');

    setTimeout(function () {
        casper.exit(code);
    }, 0);
}
