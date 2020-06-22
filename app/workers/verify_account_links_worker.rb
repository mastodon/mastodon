# frozen_string_literal: true

class VerifyAccountLinksWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: false, lock: :until_executed

  def perform(account_id)
    account = Account.find(account_id)

    account.fields.each do |field|
      next unless !field.verified? && field.verifiable?
      VerifyLinkService.new.call(field)
    end

    account.save! if account.changed?
  rescue ActiveRecord::RecordNotFound
    true
  end
end
