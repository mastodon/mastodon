Heroku guide
============

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://dashboard.heroku.com/new?button-url=https://github.com/tootsuite/mastodon&template=https://github.com/tootsuite/mastodon)

Mastodon can be run on a free [Heroku](https://heroku.com) app. It should be
noted this has limited testing and could have unpredictable results.

## Basic setup

Click the button above to start creating a Heroku app with the Mastodon repo as
the source. This tells Heroku to use the `app.json` file which does things like
prompt for config variables, set up the right buildpacks, run a postdeploy task,
and add the appropriate addons.

If you don't use the deploy button and app.json approach, you will need to do
some of that manually.

## Domain names and SSL

You can add your domain name to the Heroku app's setting, and then also use
Heroku's (free) auto renewal program for Lets Encrypt certificates, by
requesting a cert from the settings screen. You'll have to point your hostname
DNS at Heroku using the values heroku gives you on this screen, using whatever
method is appropriate for your DNS setup.

You should set the Heroku config vars of `LOCAL_DOMAIN` to your hostname, and
`LOCAL_HTTPS` to "true" as well.

## Email

Consider using [Mailgun](https://mailgun.com) or similar, who offer free plans
that should suit your interests. Look in `production.rb` to see which config
variables need to be set on Heroku for outgoing email to work.

## File storage

You will want Amazon S3 for file storage. The only exception is for development
purposes, where you may not care if files are not saved. Follow a guide online
for creating a free Amazon S3 bucket and Access Key, then enter the details.

## Deployment

You can deploy from the Heroku web interface or from the command line. Run:

  `heroku run rails db:migrate`

after you first deploy to set up the first database.

You may need to use the `heroku` CLI application to run:

  `USERNAME=yourUsername rails mastodon:make_admin`

to make yourself an admin.
