# frozen_string_literal: true

class Pubsubhubbub::UnsubscribeService < BaseService
  attr_reader :account, :callback

  def call(account, callback)
    @account  = account
    @callback = Addressable::URI.parse(callback).normalize.to_s

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
    @_subscription ||= Subscription.find_by(account: account, callback_url: callback)
  end
end
