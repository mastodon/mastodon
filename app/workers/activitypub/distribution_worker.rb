# frozen_string_literal: true

class ActivityPub::DistributionWorker
  include Sidekiq::Worker
  include Payloadable

  sidekiq_options queue: 'push'

  def perform(status_id)
    @status  = Status.find(status_id)
    @account = @status.account

    return if skip_distribution?

    if @status.private_visibility?
      specialized_delivery!
    else
      ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
        [payload, @account.id, inbox_url]
      end
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

  def specialized_delivery!
    recipients.inboxes_with_domain.group_by(&:last).each do |domain, inboxes_with_domain|
      specialized_payload = payload_for_domain(domain)
      ActivityPub::DeliveryWorker.push_bulk(inboxes_with_domain) do |(inbox_url, _)|
        [specialized_payload, @account.id, inbox_url]
      end
    end
  end

  def recipients
    # Deliver the status to all followers.
    # If the status is a reply to another local status, also forward it to that
    # status' authors' followers.
    if @status.reply? && @status.thread.account.local? && @status.distributable?
      @account.followers.or(@status.thread.account.followers)
    else
      @account.followers
    end
  end

  def inboxes
    @inboxes ||= recipients.inboxes
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(ActivityPub::ActivityPresenter.from_status(@status), ActivityPub::ActivitySerializer, signer: @account))
  end

  def payload_for_domain(domain)
    Oj.dump(serialize_payload(ActivityPub::ActivityPresenter.from_status(@status, synchronization_domain: domain), ActivityPub::ActivitySerializer, signer: @account))
  end

  def relay!
    ActivityPub::DeliveryWorker.push_bulk(Relay.enabled.pluck(:inbox_url)) do |inbox_url|
      [payload, @account.id, inbox_url]
    end
  end
end
