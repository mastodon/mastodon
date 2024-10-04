# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  helper :accounts,
         :statuses,
         :routing

  before_action :process_params
  with_options only: %i(mention favourite reblog) do
    before_action :set_status
    after_action :thread_by_conversation!
  end
  before_action :set_account, only: [:follow, :favourite, :reblog, :follow_request]
  after_action :set_list_headers!

  before_deliver :verify_functional_user

  default to: -> { email_address_with_name(@user.email, @me.username) }

  layout 'mailer'

  def mention
    return if @status.blank?

    locale_for_account(@me) do
      mail subject: default_i18n_subject(name: @status.account.acct)
    end
  end

  def follow
    locale_for_account(@me) do
      mail subject: default_i18n_subject(name: @account.acct)
    end
  end

  def favourite
    return if @status.blank?

    locale_for_account(@me) do
      mail subject: default_i18n_subject(name: @account.acct)
    end
  end

  def reblog
    return if @status.blank?

    locale_for_account(@me) do
      mail subject: default_i18n_subject(name: @account.acct)
    end
  end

  def follow_request
    locale_for_account(@me) do
      mail subject: default_i18n_subject(name: @account.acct)
    end
  end

  private

  def process_params
    @notification = params[:notification]
    @me = params[:recipient]
    @user = @me.user
    @type = action_name
    @unsubscribe_url = unsubscribe_url(token: @user.to_sgid(for: 'unsubscribe').to_s, type: @type)
  end

  def set_status
    @status = @notification.target_status
  end

  def set_account
    @account = @notification.from_account
  end

  def verify_functional_user
    throw(:abort) unless @user.functional?
  end

  def set_list_headers!
    headers(
      'List-ID' => "<#{@type}.#{@me.username}.#{Rails.configuration.x.local_domain}>",
      'List-Unsubscribe-Post' => 'List-Unsubscribe=One-Click',
      'List-Unsubscribe' => "<#{@unsubscribe_url}>"
    )
  end

  def thread_by_conversation!
    return if @status&.conversation.nil?

    conversation_message_id = "<conversation-#{@status.conversation.id}.#{@status.conversation.created_at.to_date}@#{Rails.configuration.x.local_domain}>"

    headers(
      'In-Reply-To' => conversation_message_id,
      'References' => conversation_message_id
    )
  end
end
