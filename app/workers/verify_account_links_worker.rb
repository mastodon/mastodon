# frozen_string_literal: true

class VerifyAccountLinksWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: false, lock: :until_executed

  def perform(account_id)
    account = Account.find(account_id)

    account.fields.each do |field|
      VerifyLinkService.new.call(field) if field.requires_verification?
    end

    account.save! if account.changed?
  rescue ActiveRecord::RecordNotFound
    true
  end
end
