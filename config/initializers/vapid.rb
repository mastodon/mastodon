# frozen_string_literal: true

require_relative '../../lib/mastodon/vapid_keyring'

if ENV['VAPID_PRIVATE_KEY_DUMMY']
  # Use randomly generated private key for testing
  ENV['VAPID_PRIVATE_KEY'] = Webpush::VapidKey.new.private_key
end

Rails.application.configure do
  config.x.vapid = Mastodon::VapidKeyring.new Array.wrap(ENV.fetch('VAPID_PRIVATE_KEY', nil))
end
