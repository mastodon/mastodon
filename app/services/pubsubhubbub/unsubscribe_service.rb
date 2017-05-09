# frozen_string_literal: true

class Pubsubhubbub::UnsubscribeService < BaseService
  attr_reader :account, :callback_url

  def call(account, callback_url)
    @account = account
    @callback_url = callback_url

    process_unsubscribe
  end

  private

  def process_unsubscribe
    if account.nil?
      ['Invalid topic URL', 422]
    else
      confirm_unsubscribe unless subscription.nil?
      ['', 202]
    end
  end

  def confirm_unsubscribe
    Pubsubhubbub::ConfirmationWorker.perform_async(subscription.id, 'unsubscribe')
  end

  def subscription
    @_subscription ||= Subscription.find_by(account: account, callback_url: callback_url)
  end
end
