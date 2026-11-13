# frozen_string_literal: true

require_relative '../../lib/mastodon/vapid_keyring'

[
  'VAPID_INACTIVE_PRIVATE_KEYS',
  'VAPID_PRIVATE_KEY',
].each do |key|
  value = ENV.fetch(key, '')

  next unless Rails.env.production? && value.include?('DO_NOT_USE_IN_PRODUCTION')

  abort <<~MESSAGE # rubocop:disable Rails/Exit

    It looks like you are trying to run Mastodon in production with a #{key} value from the test environment.

    Please generate fresh secrets using `bin/rails mastodon:webpush:generate_vapid_key` and use them instead.
  MESSAGE
end

Rails.application.configure do
  config.x.vapid = Mastodon::VapidKeyring.new(ENV.fetch('VAPID_INACTIVE_PRIVATE_KEYS', '').split(','), ENV.fetch('VAPID_PRIVATE_KEY', nil))
end
