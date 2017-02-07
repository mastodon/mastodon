# frozen_string_literal: true

instrumentation_hostname = ENV.fetch('INSTRUMENTATION_HOSTNAME') { 'localhost' }

ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
  event      = ActiveSupport::Notifications::Event.new(*args)
  controller = event.payload[:controller]
  action     = event.payload[:action]
  format     = event.payload[:format] || 'all'
  format     = 'all' if format == '*/*'
  status     = event.payload[:status]
  key        = "#{controller}.#{action}.#{format}.#{instrumentation_hostname}"

  ActiveSupport::Notifications.instrument :performance, action: :measure, measurement: "#{key}.total_duration", value: event.duration
  ActiveSupport::Notifications.instrument :performance, action: :measure, measurement: "#{key}.db_time", value: event.payload[:db_runtime]
  ActiveSupport::Notifications.instrument :performance, action: :measure, measurement: "#{key}.view_time", value: event.payload[:view_runtime]
  ActiveSupport::Notifications.instrument :performance, measurement: "#{key}.status.#{status}"
end
