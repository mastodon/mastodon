# frozen_string_literal: true

class Pubsubhubbub::UnsubscribeService < BaseService
  def call(account, callback)
    return ['Invalid topic URL', 422] if account.nil?

    subscription = Subscription.find_by(account: account, callback_url: callback)

    unless subscription.nil?
      Pubsubhubbub::ConfirmationWorker.perform_async(subscription.id, 'unsubscribe')
    end

    ['', 202]
  end
end
