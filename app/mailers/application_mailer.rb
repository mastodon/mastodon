# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  helper :application
  helper :instance
  helper :formatting

  after_action :set_autoreply_headers!

  protected

  def with_user_settings(user, &block)
    I18n.with_locale(user.locale || I18n.default_locale) do
      Time.use_zone(user.time_zone || ENV['DEFAULT_TIME_ZONE'] || 'UTC', &block)
    end
  end

  def set_autoreply_headers!
    headers['Precedence'] = 'list'
    headers['X-Auto-Response-Suppress'] = 'All'
    headers['Auto-Submitted'] = 'auto-generated'
  end
end
