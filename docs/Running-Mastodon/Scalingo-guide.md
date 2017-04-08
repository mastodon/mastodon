Scalingo guide
==============

[![Deploy on Scalingo](https://cdn.scalingo.com/deploy/button.svg)](https://my.scalingo.com/deploy?source=https://github.com/tootsuite/mastodon#master)

1. Click the above button.
2. Fill in the options requested.
  * You can use a .scalingo.io domain, which will be simple to set up, or you can use a custom domain.
  * You will want Amazon S3 for file storage. The only exception is for development purposes, where you may not care if files are not saved. Follow a guide online for creating a free Amazon S3 bucket and Access Key, then enter the details.
  * If you want your Mastodon to be able to send emails, configure SMTP settings here (or later). Consider using [Mailgun](https://mailgun.com) or similar, who offer free plans that should suit your interests.
3. Deploy! The app should be set up, with a working web interface and database. You can change settings and manage versions from the Scalingo dashboard.

To make yourself an admin, you can use the `scalingo` CLI: `scalingo run -e USERNAME=yourusername rails mastodon:make_admin`.
