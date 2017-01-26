# frozen_string_literal: true

StatsD.prefix              = 'mastodon'
StatsD.default_sample_rate = 1

ActiveSupport::Notifications.subscribe(/performance/) do |name, _start, _finish, _id, payload|
  action      = payload[:action] || :increment
  measurement = payload[:measurement]
  value       = payload[:value]
  key_name    = "#{name}.#{measurement}"

  StatsD.send(action.to_s, key_name, (value || 1))
end
