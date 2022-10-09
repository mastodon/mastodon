# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  layout 'plain_mailer'

  helper :accounts
  helper :languages

  def new_report(recipient, report)
    @report   = report
    @me       = recipient
    @instance = Rails.configuration.x.local_domain

    locale_for_account(@me) do
      mail to: @me.user_email, subject: I18n.t('admin_mailer.new_report.subject', instance: @instance, id: @report.id)
    end
  end

  def new_appeal(recipient, appeal)
    @appeal   = appeal
    @me       = recipient
    @instance = Rails.configuration.x.local_domain

    locale_for_account(@me) do
      mail to: @me.user_email, subject: I18n.t('admin_mailer.new_appeal.subject', instance: @instance, username: @appeal.account.username)
    end
  end

  def new_pending_account(recipient, user)
    @account  = user.account
    @me       = recipient
    @instance = Rails.configuration.x.local_domain

    locale_for_account(@me) do
      mail to: @me.user_email, subject: I18n.t('admin_mailer.new_pending_account.subject', instance: @instance, username: @account.username)
    end
  end

  def new_trends(recipient, links, tags, statuses)
    @links                  = links
    @tags                   = tags
    @statuses               = statuses
    @me                     = recipient
    @instance               = Rails.configuration.x.local_domain

    locale_for_account(@me) do
      mail to: @me.user_email, subject: I18n.t('admin_mailer.new_trends.subject', instance: @instance)
    end
  end
end
