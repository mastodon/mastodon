# frozen_string_literal: true

class ActivityPub::DistributionWorker
  include Sidekiq::Worker
  include Payloadable

  sidekiq_options queue: 'push'

  def perform(status_id)
    @status  = Status.find(status_id)
    @account = @status.account

    return if skip_distribution?

    if delegate_distribution?
      deliver_to_parent!
    else
      deliver_to_inboxes!
    end

    relay! if relayable?
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def skip_distribution?
    @status.direct_visibility?
  end

  def delegate_distribution?
    @status.limited_visibility? && @status.reply? && !@status.conversation.local?
  end

  def relayable?
    @status.public_visibility?
  end

  def deliver_to_parent!
    return if @status.conversation.inbox_url.blank?

    ActivityPub::DeliveryWorker.perform_async(payload, @account.id, @status.conversation.inbox_url)
  end

  def deliver_to_inboxes!
    ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [payload, @account.id, inbox_url, { synchronize_followers: !@status.distributable? }]
    end
  end

  def inboxes
    # Deliver the status to all followers. If the status is a reply
    # to another local status, also forward it to that status'
    # authors' followers. If the status has limited visibility,
    # deliver it to inboxes of people mentioned (no shared ones)

    @inboxes ||= begin
      if @status.limited_visibility?
        DeliveryFailureTracker.without_unavailable(Account.remote.joins(:mentions).merge(@status.mentions).pluck(:inbox_url))
      elsif @status.in_reply_to_local_account? && @status.distributable?
        @account.followers.or(@status.thread.account.followers).inboxes
      else
        @account.followers.inboxes
      end
    end
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(ActivityPub::ActivityPresenter.from_status(@status), ActivityPub::ActivitySerializer, signer: @account))
  end

  def relay!
    ActivityPub::DeliveryWorker.push_bulk(Relay.enabled.pluck(:inbox_url)) do |inbox_url|
      [payload, @account.id, inbox_url]
    end
  end
end
