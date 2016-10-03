class UnblockService < BaseService
  def call(account, target_account)
    account.unblock!(target_account) if account.blocking?(target_account)
  end
end
