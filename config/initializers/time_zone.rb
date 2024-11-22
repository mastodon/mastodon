# frozen_string_literal: true

# Raise if invalid zone is specified
Rails.application.configure do
  config.x.default_time_zone = Time.find_zone!(ENV.fetch('DEFAULT_TIME_ZONE', 'UTC')).tzinfo.name
end
