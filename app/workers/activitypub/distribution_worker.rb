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
    # Deliver the status to all followers.
    # If the status is a reply to another local status, also forward it to that
    # status' authors' followers.
    @inboxes ||= if @status.reply? && @status.thread.account.local? && @status.distributable?
                   @account.followers.or(@status.thread.account.followers).inboxes
                 else
                   @account.followers.inboxes
                 end
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
