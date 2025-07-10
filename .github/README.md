# Mastodon fork for [est.social](https://est.social/)

Forked from [Mastodon](https://github.com/mastodon/mastodon/).

This is mainly to increase character limit and to manage localization ahead of the official releases.

## Changes made

Up the char limit to 10,000:

- [compose_form_container.js](app/javascript/mastodon/features/compose/containers/compose_form_container.js)
- [instance_serializer.rb](app/serializers/rest/instance_serializer.rb)
- [v1/instance_serializer.rb](app/serializers/rest/v1/instance_serializer.rb)
- [status_length_validator.rb](app/validators/status_length_validator.rb)

Increase the feed item count to 10,000:

- [feed_manager.rb](app/lib/feed_manager.rb)
