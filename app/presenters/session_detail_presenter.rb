# frozen_string_literal: true

class SessionDetailPresenter
  attr_reader :remote_ip, :user_agent

  def initialize(user, remote_ip, user_agent, timestamp)
    @user = user
    @remote_ip = remote_ip
    @user_agent = user_agent
    @timestamp = timestamp
  end

  def to_partial_path
    'user_mailer/session_detail'
  end

  def browser
    I18n.t("sessions.browsers.#{browser_id}", default: browser_id)
  end

  def platform
    I18n.t("sessions.platforms.#{platform_id}", default: platform_id)
  end

  def access_time
    @timestamp.in_time_zone(@user.time_zone.presence)
  end

  private

  def browser_id
    detection.id.to_s
  end

  def platform_id
    detection.platform.id.to_s
  end

  def detection
    @detection ||= Browser.new(@user_agent)
  end
end
