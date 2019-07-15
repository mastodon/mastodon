# frozen_string_literal: true

class ActivityPub::DistributionWorker
  include Sidekiq::Worker
  include Payloadable

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
    @status.public_visibility? && signing_enabled?
  end

  def reply_forwardable?
    @status.reply? && replied_to_account.local? && @status.distributable? && signing_enabled?
  end

  def inboxes
    # Deliver the status to all followers.
    # If the status is a reply to another local status, also forward it to that
    # status' authors' followers.

    @inboxes ||= begin
      if reply_forwardable?
        @account.followers.or(replied_to_account.followers).inboxes
      else
        @account.followers.inboxes
      end
    end
  end

  def replied_to_account
    @replied_to_account ||= @status.thread.account
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(@status, ActivityPub::ActivitySerializer, signer: @account))
  end

  def relay!
    ActivityPub::DeliveryWorker.push_bulk(Relay.enabled.pluck(:inbox_url)) do |inbox_url|
      [payload, @account.id, inbox_url]
    end
  end
end
