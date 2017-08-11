# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  helper :instance

  protected

  def locale_for_account(account)
    I18n.with_locale(account.user_locale || I18n.default_locale) do
      yield
    end
  end
end
