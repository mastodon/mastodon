# frozen_string_literal: true

%w(
  ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
  ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT
  ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY
).each do |key|
  ENV.fetch(key) do
    raise <<~MESSAGE

      The ActiveRecord encryption feature requires that these variables are set:

        - ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
        - ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT
        - ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY

      Run `bin/rails db:encryption:init` to generate values and then assign the environment variables.
    MESSAGE
  end
end

Rails.application.configure do
  config.active_record.encryption.deterministic_key = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY')
  config.active_record.encryption.key_derivation_salt = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT')
  config.active_record.encryption.primary_key = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY')
end
