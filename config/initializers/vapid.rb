# frozen_string_literal: true

Rails.application.configure do
  # You can generate the keys using the following command (first is the private key, second is the public one)
  # You should only generate this once per instance. If you later decide to change it, all push subscription will
  # be invalidated, requiring the users to access the website again to resubscribe.
  #
  # Generate with `rake mastodon:webpush:generate_vapid_key` task (`docker-compose run --rm web rake mastodon:webpush:generate_vapid_key` if you use docker compose)
  #
  # For more information visit https://rossta.net/blog/using-the-web-push-api-with-vapid.html

  if Rails.env.production?
    config.x.vapid_private_key = ENV['VAPID_PRIVATE_KEY']
    config.x.vapid_public_key = ENV['VAPID_PUBLIC_KEY']
  end
end
