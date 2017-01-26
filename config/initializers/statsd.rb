# frozen_string_literal: true
RESERVED_CHARACTERS_REGEX = /[\:\|\@]/

StatsD.prefix              = 'mastodon'
StatsD.default_sample_rate = 1

def clean_name(str)
  str.gsub('::', '.').gsub(RESERVED_CHARACTERS_REGEX, '_')
end

ActiveSupport::Notifications.subscribe(/performance/) do |name, _start, _finish, _id, payload|
  action      = payload[:action] || :increment
  measurement = payload[:measurement]
  value       = payload[:value]
  key_name    = clean_name("#{name}.#{measurement}")

  StatsD.send(action.to_s, key_name, (value || 1))
end
