# frozen_string_literal: true

require_relative '../../lib/mastodon/vapid_keyring'

Rails.application.configure do
  config.x.vapid = Mastodon::VapidKeyring.new Array.wrap(ENV.fetch('VAPID_PRIVATE_KEY', nil))
end
