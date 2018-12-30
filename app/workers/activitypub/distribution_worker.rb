# frozen_string_literal: true

class ActivityPub::DistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(status_id)
    @status  = Status.find(status_id)
    @account = @status.account

    return if skip_distribution?

    ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [payload, @account.id, inbox_url]
    end

    relay! if relayable?
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def skip_distribution?
    @status.direct_visibility? || @status.limited_visibility?
  end

  def relayable?
    @status.public_visibility?
  end

  def inboxes
    @inboxes ||= @account.followers.inboxes
  end

  def signed_payload
    Oj.dump(ActivityPub::LinkedDataSignature.new(unsigned_payload).sign!(@account))
  end

  def unsigned_payload
    ActiveModelSerializers::SerializableResource.new(
      @status,
      serializer: ActivityPub::ActivitySerializer,
      adapter: ActivityPub::Adapter
    ).as_json
  end

  def payload
    @payload ||= @status.distributable? ? signed_payload : Oj.dump(unsigned_payload)
  end

  def relay!
    ActivityPub::DeliveryWorker.push_bulk(Relay.enabled.pluck(:inbox_url)) do |inbox_url|
      [payload, @account.id, inbox_url]
    end
  end
end
