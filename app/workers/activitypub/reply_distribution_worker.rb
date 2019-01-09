# frozen_string_literal: true

# Obsolete but kept around to make sure existing jobs do not fail after upgrade.
# Should be removed in a subsequent release.

class ActivityPub::ReplyDistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(status_id)
    @status  = Status.find(status_id)
    @account = @status.thread&.account

    return unless @account.present? && @status.distributable?

    ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [payload, @status.account_id, inbox_url]
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def inboxes
    @inboxes ||= @account.followers.inboxes
  end

  def signed_payload
    Oj.dump(ActivityPub::LinkedDataSignature.new(unsigned_payload).sign!(@status.account))
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
end
