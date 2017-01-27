Administration guide
=================

So, you have a working Mastodon instance... now what?

## Administration web interface

A user that is designated as `admin = TRUE` in the database is able to access a suite of administration tools:

* View, edit, silence, or suspend users - https://yourmastodon.instance/admin/accounts
* View PubSubHubbub subscriptions - https://yourmastodon.instance/admin/pubsubhubbub
* View domain blocks - https://yourmastodon.instance/admin/domain_blocks
* Sidekiq dashboard - https://yourmastodon.instance/sidekiq
* PGHero dashboard for PostgreSQL - https://yourmastodon.instance/pghero
* Edit site settings - https://yourmastodon.instance/admin/settings

## Site settings

Your site settings are stored in the `settings` database table, and editable through the admin interface at https://yourmastodon.instance/admin/settings.

You are able to set the following settings:

- Contact username
- Contact email
- Site description
- Site extended description

You may wish to use the extended description (shown at https://yourmastodon.instance/about/more ) to display content guidelines or a user agreement (see https://mastodon.social/about/more for an example).