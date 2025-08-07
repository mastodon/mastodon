# frozen_string_literal: true

# Security Monitoring and Alerting System
class SecurityMonitor
  include Redisable

  ALERT_THRESHOLDS = {
    csrf_failures: 10,      # per hour
    rate_limit_hits: 50,    # per hour
    failed_logins: 20,      # per hour
    suspicious_ips: 5       # unique IPs per hour
  }.freeze

  def self.log_security_event(event_type, details = {})
    timestamp = Time.now.utc
    event_data = {
      type: event_type,
      timestamp: timestamp.iso8601,
      details: details
    }

    # Log to Rails logger
    Rails.logger.warn("SECURITY_EVENT: #{event_data.to_json}")

    # Store in Redis for real-time monitoring
    redis_key = "security:events:#{event_type}:#{timestamp.strftime('%Y%m%d%H')}"
    redis.lpush(redis_key, event_data.to_json)
    redis.expire(redis_key, 24.hours)

    # Check thresholds and send alerts if needed
    check_alert_thresholds(event_type, timestamp)
  end

  def self.log_csrf_failure(ip, path, user_agent = nil)
    log_security_event('csrf_failure', {
      ip: ip,
      path: path,
      user_agent: user_agent
    })
  end

  def self.log_rate_limit_hit(ip, throttle_name, path = nil)
    log_security_event('rate_limit_hit', {
      ip: ip,
      throttle: throttle_name,
      path: path
    })
  end

  def self.log_failed_login(ip, email = nil, reason = nil)
    log_security_event('failed_login', {
      ip: ip,
      email: email,
      reason: reason
    })
  end

  def self.log_suspicious_activity(ip, activity_type, details = {})
    log_security_event('suspicious_activity', {
      ip: ip,
      activity_type: activity_type,
      details: details
    })
  end

  private

  def self.check_alert_thresholds(event_type, timestamp)
    return unless ALERT_THRESHOLDS.key?(event_type.to_sym)

    hour_key = "security:events:#{event_type}:#{timestamp.strftime('%Y%m%d%H')}"
    event_count = redis.llen(hour_key)
    threshold = ALERT_THRESHOLDS[event_type.to_sym]

    if event_count >= threshold
      send_security_alert(event_type, event_count, threshold)
    end
  end

  def self.send_security_alert(event_type, count, threshold)
    alert_data = {
      event_type: event_type,
      count: count,
      threshold: threshold,
      timestamp: Time.now.utc.iso8601,
      server: ENV['HOSTNAME'] || 'unknown'
    }

    Rails.logger.error("SECURITY_ALERT: #{alert_data.to_json}")

    # Send to external monitoring if configured
    if ENV['SECURITY_WEBHOOK_URL'].present?
      send_webhook_alert(alert_data)
    end

    # Send email to admins if configured
    if ENV['SECURITY_ALERT_EMAIL'].present?
      send_email_alert(alert_data)
    end
  end

  def self.send_webhook_alert(alert_data)
    begin
      HTTP.post(ENV['SECURITY_WEBHOOK_URL'], json: alert_data)
    rescue => e
      Rails.logger.error("Failed to send security webhook: #{e.message}")
    end
  end

  def self.send_email_alert(alert_data)
    begin
      AdminMailer.security_alert(alert_data).deliver_now
    rescue => e
      Rails.logger.error("Failed to send security email alert: #{e.message}")
    end
  end

  def self.redis
    @redis ||= Redis.new(REDIS_CONFIGURATION.cache)
  end
end

# Add security monitoring to existing controllers
module SecurityMonitoringConcern
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::InvalidAuthenticityToken do |exception|
      SecurityMonitor.log_csrf_failure(
        request.remote_ip,
        request.path,
        request.user_agent
      )
      raise exception
    end
  end
end

# Apply to ApplicationController
ApplicationController.class_eval do
  include SecurityMonitoringConcern
end
