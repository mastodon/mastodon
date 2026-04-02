# frozen_string_literal: true

class EmailSubscriptionMailer < ApplicationMailer
  include BulkMailSettingsConcern
  include Redisable

  layout 'mailer'

  helper :accounts
  helper :routing
  helper :statuses

  before_action :set_subscription
  before_action :set_unsubscribe_url
  before_action :set_instance
  before_action :set_skip_preferences_link

  after_action :use_bulk_mail_delivery_settings, except: [:confirmation]
  after_action :set_list_headers

  default to: -> { @subscription.email }

  def confirmation
    I18n.with_locale(locale) do
      mail subject: default_i18n_subject
    end
  end

  def notification(statuses)
    @statuses = statuses

    I18n.with_locale(locale) do
      mail subject: I18n.t(@statuses.size == 1 ? 'singular' : 'plural', scope: 'email_subscription_mailer.notification.subject', name: @subscription.account.display_name, excerpt: @statuses.first.text.truncate(17))
    end
  end

  private

  def set_list_headers
    headers(
      'List-ID' => "<#{@subscription.account.username}.#{Rails.configuration.x.local_domain}>",
      'List-Unsubscribe-Post' => 'List-Unsubscribe=One-Click',
      'List-Unsubscribe' => "<#{@unsubscribe_url}>"
    )
  end

  def set_subscription
    @subscription = params[:subscription]
  end

  def set_unsubscribe_url
    @unsubscribe_url = unsubscribe_url(token: @subscription.to_sgid(for: 'unsubscribe').to_s)
  end

  def set_instance
    @instance = Rails.configuration.x.local_domain
  end

  def set_skip_preferences_link
    @skip_preferences_link = true
  end

  def locale
    @subscription.locale.presence || I18n.default_locale
  end
end
