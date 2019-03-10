# frozen_string_literal: true

class ActivityPub::DistributePollUpdateWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', unique: :until_executed, retry: 0

  def perform(status_id)
    @status  = Status.find(status_id)
    @account = @status.account

    return unless @status.poll

    ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
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
    target_accounts = @status.mentions.map(&:account).reject(&:local?)
    target_accounts += @status.reblogs.map(&:account).reject(&:local?)
    target_accounts += @status.poll.votes.map(&:account).reject(&:local?)
    target_accounts.uniq!(&:id)
    @inboxes = target_accounts.select(&:activitypub?).pluck(&:inbox_url)
    @inboxes += @account.followers.inboxes unless @status.direct_visibility?
    @inboxes.uniq!
    @inboxes
  end

  def signed_payload
    Oj.dump(ActivityPub::LinkedDataSignature.new(unsigned_payload).sign!(@account))
  end

  def unsigned_payload
    ActiveModelSerializers::SerializableResource.new(
      @status,
      serializer: ActivityPub::UpdatePollSerializer,
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
