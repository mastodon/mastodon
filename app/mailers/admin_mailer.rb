# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  layout 'plain_mailer'

  helper :accounts
  helper :languages

  before_action { @me = params[:recipient] }
  before_action :set_instance

  default to: -> { @me.user_email }

  def new_report(report)
    @report = report

    locale_for_account(@me) do
      mail subject: I18n.t('admin_mailer.new_report.subject', instance: @instance, id: @report.id)
    end
  end

  def new_appeal(appeal)
    @appeal = appeal

    locale_for_account(@me) do
      mail subject: I18n.t('admin_mailer.new_appeal.subject', instance: @instance, username: @appeal.account.username)
    end
  end

  def new_pending_account(user)
    @account = user.account

    locale_for_account(@me) do
      mail subject: I18n.t('admin_mailer.new_pending_account.subject', instance: @instance, username: @account.username)
    end
  end

  def new_trends(links, tags, statuses)
    @links                  = links
    @tags                   = tags
    @statuses               = statuses

    locale_for_account(@me) do
      mail subject: I18n.t('admin_mailer.new_trends.subject', instance: @instance)
    end
  end

  private

  def set_instance
    @instance = Rails.configuration.x.local_domain
  end
end
