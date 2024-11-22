# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  layout 'admin_mailer'

  helper :accounts
  helper :languages

  before_action :process_params
  before_action :set_instance

  after_action :set_important_headers!, only: :new_critical_software_updates

  default to: -> { @me.user_email }

  def new_report(report)
    @report = report

    locale_for_account(@me) do
      mail subject: default_i18n_subject(instance: @instance, id: @report.id)
    end
  end

  def new_appeal(appeal)
    @appeal = appeal

    locale_for_account(@me) do
      mail subject: default_i18n_subject(instance: @instance, username: @appeal.account.username)
    end
  end

  def new_pending_account(user)
    @account = user.account

    locale_for_account(@me) do
      mail subject: default_i18n_subject(instance: @instance, username: @account.username)
    end
  end

  def new_trends(links, tags, statuses)
    @links                  = links
    @tags                   = tags
    @statuses               = statuses

    locale_for_account(@me) do
      mail subject: default_i18n_subject(instance: @instance)
    end
  end

  def new_software_updates
    @software_updates = SoftwareUpdate.all.to_a.sort_by(&:gem_version)

    locale_for_account(@me) do
      mail subject: default_i18n_subject(instance: @instance)
    end
  end

  def new_critical_software_updates
    @software_updates = SoftwareUpdate.where(urgent: true).to_a.sort_by(&:gem_version)

    locale_for_account(@me) do
      mail subject: default_i18n_subject(instance: @instance)
    end
  end

  def auto_close_registrations
    locale_for_account(@me) do
      mail subject: default_i18n_subject(instance: @instance)
    end
  end

  private

  def process_params
    @me = params[:recipient]
  end

  def set_instance
    @instance = Rails.configuration.x.local_domain
  end

  def set_important_headers!
    headers(
      'Importance' => 'high',
      'Priority' => 'urgent',
      'X-Priority' => '1'
    )
  end
end
