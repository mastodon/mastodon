# frozen_string_literal: true

class AccountPurgeWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id, options = {})
    account = Account.find_by(id: account_id)
    return true if account.nil?

    PurgeAccountService.new.call(account, **options.symbolize_keys)
  rescue PurgeAccountService::StageTimeoutError => e
    AccountPurgeWorker.perform_async(account_id, options.merge('stage' => e.stage))
  end
end
