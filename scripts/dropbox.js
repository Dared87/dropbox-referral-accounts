"use strict";

var casper = require('casper').create({
        pageSettings: {
            userAgent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36',
            loadImages: false,
            loadPlugins: false
        }
    }),
    account,
    action,
    actions,
    dropboxUrl,
    timeout;

if ( ! casper.cli.has(7) || casper.cli.has(8)) {
    casper.log('Usage: manage-account.js <action> <dropboxUrl> <accountId> <accountFirstName> <accountLastName> <accountEmail> <accountPassword> <timeout>');
    casper.exit(1);
}

action = casper.cli.get(0);
dropboxUrl = casper.cli.get(1);
timeout = parseInt(casper.cli.get(7)) * 1000;

if (action !== 'link' && action !== 'create') {
    casper.log('The action must be either "link" or "create".');
    casper.exit(1);
}

// Converting to string is essential for "numbers-only" passwords, otherwise Dropbox password field filling bugs.
account = {
    firstName: String(casper.cli.get(3)),
    lastName: String(casper.cli.get(4)),
    password: String(casper.cli.get(6)),
    email: String(casper.cli.get(5).replace(/%d/, casper.cli.get(2)))
};

// Handling timeout
casper.options.waitTimeout = timeout;
console.log('Set CasperJS timeout to : ' + casper.options.waitTimeout + ' milliseconds.');

actions = {
    create: function () {
        var form = 'form[action="/ajax_register"] ',
            formField = form +'input',
            formButton = form +'button.login-button',
            formFirstNameHiddenLabel = formField +'[name="fname"] + label[style*="display"]';

        this.waitForSelector(formButton, function () {
            this.sendKeys(formField +'[name="fname"]', account.firstName);
            this.sendKeys(formField +'[name="lname"]', account.lastName);
            this.sendKeys(formField +'[name="email"]', account.email);
            this.sendKeys(formField +'[name="password"]', account.password);

            // To check if Javascript is loaded, we ensure labels disappeared after the inputs were filled.
            this.waitForSelector(formFirstNameHiddenLabel, function () {

                // As we evaluate code with jQuery, it's better to wait for JS to be loaded to handle this one.
                var termsAndConditionsIsChecked = this.evaluate(function (formField) {
                    return jQuery(formField + '[name="tos_agree"]:checked').length === 1;
                }, formField);

                if (!termsAndConditionsIsChecked) {
                    this.click(formField + '[name="tos_agree"]');
                }

                this.click(formButton);

                this.waitForUrl('https://www.dropbox.com/install?os=lnx', function () {
                    var selector = '//*[@id="linux-install-content"]/h2',
                        text = 'Dropbox Headless Install via command line';

                    this.waitForSelector(selectorContains(selector, text), function () {
                        safeExit(this, 0, 'The account was created successfully !');

                    }, function () { safeExit(this, 1, 'Timeout when looking for the flash message asserting the account creation.'); });
                }, function () { safeExit(this, 1, 'Timeout when waiting for the Dropbox installation page to load.'); });
            }, function () { safeExit(this, 1, 'Timeout when checking that the form\'s label disappeared (meaning the JS has been loaded).'); });
        }, function () { safeExit(this, 1, 'Timeout when looking for the creation form\'s button.'); });
    },
    link: function () {
        var form = 'form[action="/cli_link_nonce"] ',
            formField = form +'input',
            formButton = form +'button.login-button',
            formButtonEnabled = formButton +':not([disabled="True"])';

        // As this button is disabled if Javascript isn't enabled, we ensure Javascript is loaded before starting.
        this.waitForSelector(formButton, function () {
            this.sendKeys(formField +'[name="login_email"]', account.email);
            this.sendKeys(formField +'[name="login_password"]', account.password);

            var rememberMeIsChecked = this.evaluate(function (formField) {
                return jQuery(formField +'[name="remember_me"]:checked').length === 1;
            }, formField);

            if (rememberMeIsChecked) {
                this.click(formField +'[name="remember_me"]');
            }

            this.waitForSelector(formButtonEnabled, function () {
                this.click(formButtonEnabled);

                this.waitWhileVisible('.login-loading-indicator', function () {
                    var selector = '//*[@id="page-content"]/div/div[2]/p[1]',
                        text = 'Your computer was successfully linked to your account';

                    this.waitUntilVisible(selectorContains(selector, text), function () {
                        safeExit(this, 0, 'The account was linked successfully !');

                    }, function () { safeExit(this, 1, 'Timeout when looking for the message asserting the account linking.'); });
                }, function () { safeExit(this, 1, 'Timeout when checking that the loading indicator disappeared.'); });
            }, function () { safeExit(this, 1, 'Timeout when checking that the form\'s button was enabled (meaning the JS has been loaded).'); });
        }, function () { safeExit(this, 1, 'Timeout when looking for the linking form\'s button.'); });
    }
};

casper.start(dropboxUrl);
casper.then(actions[action]);
casper.run();

function selectorContains(selector, text)
{
    return {
        type: 'xpath',
        path: selector + '[contains(., "' + text + '")]'
    }
}

function safeExit(casper, code, message)
{
    if (code > 0) {
        casper.capture('screenshots/error_exit_code_' + code + '_timestamp_' + new Date().getTime() + '.png');
    }
    if (message !== undefined) {
        casper.log(message, (code > 0 ? 'error' : 'info'));
    }

    setTimeout(function () {
        phantom.exit(code);
    }, 0);
}
