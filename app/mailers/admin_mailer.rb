# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  helper StreamEntriesHelper

  def new_report(recipient, report)
    @report   = report
    @me       = recipient
    @instance = Rails.configuration.x.local_domain

    locale_for_account(@me) do
      mail to: @me.user_email, subject: I18n.t('admin_mailer.new_report.subject', instance: @instance, id: @report.id)
    end
  end
end
