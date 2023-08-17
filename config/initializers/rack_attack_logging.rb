# frozen_string_literal: true

ActiveSupport::Notifications.subscribe(/rack_attack/) do |_name, _start, _finish, _request_id, payload|
  req = payload[:request]

  next unless [:throttle, :blacklist].include? req.env['rack.attack.match_type']

  Rails.logger.info("Rate limit hit (#{req.env['rack.attack.match_type']}): #{req.ip} #{req.request_method} #{req.fullpath}")
end
