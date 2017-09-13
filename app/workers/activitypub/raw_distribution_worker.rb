# frozen_string_literal: true

class ActivityPub::RawDistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(json, source_account_id)
    @account = Account.find(source_account_id)

    ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [json, @account.id, inbox_url]
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def inboxes
    @inboxes ||= @account.followers.inboxes
  end
end
