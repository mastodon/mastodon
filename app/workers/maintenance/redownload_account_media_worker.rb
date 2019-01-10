# frozen_string_literal: true

class Maintenance::RedownloadAccountMediaWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: false

  def perform(account_id)
    account = account_id.is_a?(Account) ? account_id : Account.find(account_id)
    account.reset_avatar!
    account.reset_header!
    account.save
  rescue ActiveRecord::RecordNotFound
    true
  end
end
