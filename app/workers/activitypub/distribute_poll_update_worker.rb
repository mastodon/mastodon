# frozen_string_literal: true

class ActivityPub::DistributePollUpdateWorker
  include Sidekiq::Worker
  include Payloadable

  sidekiq_options queue: 'push', lock: :until_executed, retry: 0

  def perform(status_id)
    @status  = Status.find(status_id)
    @account = @status.account

    return unless @status.preloadable_poll

    ActivityPub::DeliveryWorker.push_bulk(inboxes, limit: 1_000) do |inbox_url|
      [payload, @account.id, inbox_url]
    end

    relay! if relayable?
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def relayable?
    @status.public_visibility?
  end

  def inboxes
    return @inboxes if defined?(@inboxes)

    @inboxes = [@status.mentions, @status.reblogs, @status.preloadable_poll.votes].flat_map do |relation|
      relation.includes(:account).map do |record|
        record.account.preferred_inbox_url if !record.account.local? && record.account.activitypub?
      end
    end

    @inboxes.concat(@account.followers.inboxes) unless @status.direct_visibility?
    @inboxes.uniq!
    @inboxes.compact!
    @inboxes
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(@status, ActivityPub::UpdatePollSerializer, signer: @account))
  end

  def relay!
    ActivityPub::DeliveryWorker.push_bulk(Relay.enabled.pluck(:inbox_url)) do |inbox_url|
      [payload, @account.id, inbox_url]
    end
  end
end
