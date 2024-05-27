# frozen_string_literal: true

%w(
  ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
  ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT
  ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY
).each do |key|
  value = ENV.fetch(key) do
    abort <<~MESSAGE

      Mastodon now requires that these variables are set:

        - ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
        - ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT
        - ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY

      Run `bin/rails db:encryption:init` to generate new secrets and then assign the environment variables.
    MESSAGE
  end

  next unless Rails.env.production? && value.end_with?('DO_NOT_USE_IN_PRODUCTION')

  abort <<~MESSAGE

    It looks like you are trying to run Mastodon in production with a #{key} value from the test environment.

    Please generate fresh secrets using `bin/rails db:encryption:init` and use them instead.
  MESSAGE
end

Rails.application.configure do
  config.active_record.encryption.deterministic_key = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY')
  config.active_record.encryption.key_derivation_salt = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT')
  config.active_record.encryption.primary_key = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY')
end
