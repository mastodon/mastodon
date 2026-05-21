# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  layout 'admin_mailer'

  helper :accounts
  helper :languages

  before_action :process_params
  before_action :set_instance

  after_action :set_important_headers!, only: :new_critical_software_updates

  around_action :set_locale

  default to: -> { @me.user_email }

  def new_report(report)
    @report = report

    mail subject: default_i18n_subject(instance: @instance, id: @report.id)
  end

  def new_appeal(appeal)
    @appeal = appeal

    mail subject: default_i18n_subject(instance: @instance, username: @appeal.account.username)
  end

  def new_pending_account(user)
    @account = user.account

    mail subject: default_i18n_subject(instance: @instance, username: @account.username)
  end

  def new_trends(links, tags, statuses)
    @links                  = links
    @tags                   = tags
    @statuses               = statuses

    mail subject: default_i18n_subject(instance: @instance)
  end

  def new_software_updates
    @software_updates = SoftwareUpdate.by_version

    mail subject: default_i18n_subject(instance: @instance)
  end

  def new_critical_software_updates
    @software_updates = SoftwareUpdate.urgent.by_version

    mail subject: default_i18n_subject(instance: @instance)
  end

  def auto_close_registrations
    mail subject: default_i18n_subject(instance: @instance)
  end

  private

  def process_params
    @me = params[:recipient]
  end

  def set_instance
    @instance = Rails.configuration.x.local_domain
  end

  def set_locale(&block)
    locale_for_account(@me, &block)
  end

  def set_important_headers!
    headers(
      'Importance' => 'high',
      'Priority' => 'urgent',
      'X-Priority' => '1'
    )
  end
end
