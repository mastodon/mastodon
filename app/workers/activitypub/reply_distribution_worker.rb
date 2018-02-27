# frozen_string_literal: true

class ActivityPub::ReplyDistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(status_id)
    @status  = Status.find(status_id)
    @account = @status.thread&.account

    return if @account.nil? || skip_distribution?

    ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [signed_payload, @status.account_id, inbox_url]
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def skip_distribution?
    @status.private_visibility? || @status.direct_visibility?
  end

  def inboxes
    @inboxes ||= @account.followers.inboxes
  end

  def signed_payload
    @signed_payload ||= Oj.dump(ActivityPub::LinkedDataSignature.new(payload).sign!(@status.account))
  end

  def payload
    @payload ||= ActiveModelSerializers::SerializableResource.new(
      @status,
      serializer: ActivityPub::ActivitySerializer,
      adapter: ActivityPub::Adapter
    ).as_json
  end
end
