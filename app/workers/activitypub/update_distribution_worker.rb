# frozen_string_literal: true

class ActivityPub::UpdateDistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(account_id)
    @account = Account.find(account_id)

    ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [signed_payload, @account.id, inbox_url]
    end

    ActivityPub::DeliveryWorker.push_bulk(Relay.enabled.pluck(:inbox_url)) do |inbox_url|
      [signed_payload, @account.id, inbox_url]
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def inboxes
    @inboxes ||= @account.followers.inboxes
  end

  def signed_payload
    @signed_payload ||= Oj.dump(ActivityPub::LinkedDataSignature.new(payload).sign!(@account))
  end

  def payload
    @payload ||= ActiveModelSerializers::SerializableResource.new(
      @account,
      serializer: ActivityPub::UpdateSerializer,
      adapter: ActivityPub::Adapter
    ).as_json
  end
end
