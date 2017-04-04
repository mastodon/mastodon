Heroku guide
============

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://dashboard.heroku.com/new?button-url=https://github.com/tootsuite/mastodon&template=https://github.com/tootsuite/mastodon)

Mastodon can theoretically run indefinitely on a free [Heroku](https://heroku.com) app. It should be noted this has limited testing and could have unpredictable results.

1. Click the above button.
2. Fill in the options requested.
  * You can use a .herokuapp.com domain, which will be simple to set up, or you can use a custom domain. If you want a custom domain and HTTPS, you will need to upgrade to a paid plan (to use Heroku's SSL features), or set up [CloudFlare](https://cloudflare.com) who offer free "Flexible SSL" (note: CloudFlare have some undefined limits on WebSockets. So far, no one has reported hitting concurrent connection limits).
  * You will want Amazon S3 for file storage. The only exception is for development purposes, where you may not care if files are not saved. Follow a guide online for creating a free Amazon S3 bucket and Access Key, then enter the details.
  * If you want your Mastodon to be able to send emails, configure SMTP settings here (or later). Consider using [Mailgun](https://mailgun.com) or similar, who offer free plans that should suit your interests.
3. Deploy! The app should be set up, with a working web interface and database. You can change settings and manage versions from the Heroku dashboard.

You may need to use the `heroku` CLI application to modify the database directly to give yourself administration rights.
