# frozen_string_literal: true

# Raise if invalid zone is specified
Time.find_zone!(ENV.fetch('DEFAULT_TIME_ZONE', nil))
