# frozen_string_literal: true

class NotificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', retry: 10, dead: false

  sidekiq_retry_in do |count|
    if count < 3
      5 * (count + 1)
    else
      (count ** 4) + 15 + (rand(30) * (count + 1))
    end
  end

  def perform(xml, source_account_id, target_account_id)
    SendInteractionService.new.call(xml, Account.find(source_account_id), Account.find(target_account_id))
  end
end
