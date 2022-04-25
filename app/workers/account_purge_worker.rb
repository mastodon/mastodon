# frozen_string_literal: true

class AccountPurgeWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id, options = {})
    account = Account.find_by(id: account_id)
    return true if account.nil?

    PurgeAccountService.new.call(account, **options.with_indifferent_access)
  end
end
