# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  helper :application
  helper :instance
  helper :formatting

  after_action :set_autoreply_headers!

  protected

  def locale_for_account(account, &block)
    I18n.with_locale(account.user_locale || I18n.default_locale, &block)
  end

  def set_autoreply_headers!
    headers(
      'Auto-Submitted' => 'auto-generated',
      'Precedence' => 'list',
      'X-Auto-Response-Suppress' => 'All'
    )
  end
end
