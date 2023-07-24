# frozen_string_literal: true

class UpdateStatusIndexWorker
  include Sidekiq::Worker

  def perform(account_id)
    account = Account.find(account_id)
    return unless account

    account.update_statuses_index!
  end
end
