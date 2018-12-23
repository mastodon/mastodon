# frozen_string_literal: true

class RemoveStatusService < BaseService
  include StreamEntryRenderer

  def call(status)
    @payload      = Oj.dump(event: :delete, payload: status.id.to_s)
    @status       = status
    @account      = status.account
    @tags         = status.tags.pluck(:name).to_a
    @mentions     = status.mentions.includes(:account).to_a
    @reblogs      = status.reblogs.to_a
    @stream_entry = status.stream_entry

    remove_from_self if status.account.local?
    remove_from_followers
    remove_from_affected
    remove_reblogs
    remove_from_hashtags
    remove_from_public

    @status.destroy!

    return unless @account.local?

    remove_from_remote_followers
    remove_from_remote_affected
  end

  private

  def remove_from_self
    unpush(:home, @account, @status)
  end

  def remove_from_followers
    @account.followers.local.find_each do |follower|
      unpush(:home, follower, @status)
    end
  end

  def remove_from_affected
    @mentions.map(&:account).select(&:local?).each do |account|
      Redis.current.publish("timeline:#{account.id}", @payload)
    end
  end

  def remove_from_remote_affected
    # People who got mentioned in the status, or who
    # reblogged it from someone else might not follow
    # the author and wouldn't normally receive the
    # delete notification - so here, we explicitly
    # send it to them

    target_accounts = (@mentions.map(&:account).reject(&:local?) + @reblogs.map(&:account).reject(&:local?)).uniq(&:id)

    # Ostatus
    NotificationWorker.push_bulk(target_accounts.select(&:ostatus?).uniq(&:domain)) do |target_account|
      [salmon_xml, @account.id, target_account.id]
    end

    # ActivityPub
    ActivityPub::DeliveryWorker.push_bulk(target_accounts.select(&:activitypub?).uniq(&:inbox_url)) do |target_account|
      [signed_activity_json, @account.id, target_account.inbox_url]
    end
  end

  def remove_from_remote_followers
    # OStatus
    Pubsubhubbub::RawDistributionWorker.perform_async(salmon_xml, @account.id)

    # ActivityPub
    ActivityPub::DeliveryWorker.push_bulk(@account.followers.inboxes) do |inbox_url|
      [signed_activity_json, @account.id, inbox_url]
    end
  end

  def salmon_xml
    @salmon_xml ||= stream_entry_to_xml(@stream_entry)
  end

  def signed_activity_json
    @signed_activity_json ||= Oj.dump(ActivityPub::LinkedDataSignature.new(activity_json).sign!(@account))
  end

  def activity_json
    @activity_json ||= ActiveModelSerializers::SerializableResource.new(
      @status,
      serializer: @status.reblog? ? ActivityPub::UndoAnnounceSerializer : ActivityPub::DeleteSerializer,
      adapter: ActivityPub::Adapter
    ).as_json
  end

  def remove_reblogs
    # We delete reblogs of the status before the original status,
    # because once original status is gone, reblogs will disappear
    # without us being able to do all the fancy stuff

    @reblogs.each do |reblog|
      RemoveStatusService.new.call(reblog)
    end
  end

  def unpush(type, receiver, status)
    FeedManager.instance.unpush(type, receiver, status)
  end

  def remove_from_hashtags
    return unless @status.public_visibility?

    @tags.each do |hashtag|
      Redis.current.publish("timeline:hashtag:#{hashtag}", @payload)
      Redis.current.publish("timeline:hashtag:#{hashtag}:local", @payload) if @status.local?
    end
  end

  def remove_from_public
    return unless @status.public_visibility?

    Redis.current.publish('timeline:public', @payload)
    Redis.current.publish('timeline:public:local', @payload) if @status.local?
  end

  def redis
    Redis.current
  end
end
