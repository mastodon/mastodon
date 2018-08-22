# frozen_string_literal: true

class RemoveStatusService < BaseService
  include StreamEntryRenderer

  def call(status, **options)
    @payload      = Oj.dump(event: :delete, payload: status.id.to_s)
    @status       = status
    @account      = status.account
    @tags         = status.tags.pluck(:name).to_a
    @mentions     = status.mentions.includes(:account).to_a
    @reblogs      = status.reblogs.to_a
    @stream_entry = status.stream_entry
    @options      = options

    remove_from_self if status.account.local?
    remove_from_followers
    remove_from_lists
    remove_from_affected
    remove_reblogs
    remove_from_hashtags
    remove_from_public
    remove_from_media if status.media_attachments.any?
    remove_from_direct if status.direct_visibility?

    @status.destroy!

    # There is no reason to send out Undo activities when the
    # cause is that the original object has been removed, since
    # original object being removed implicitly removes reblogs
    # of it. The Delete activity of the original is forwarded
    # separately.
    return if !@account.local? || @options[:original_removed]

    remove_from_remote_followers
    remove_from_remote_affected
  end

  private

  def remove_from_self
    FeedManager.instance.unpush_from_home(@account, @status)
  end

  def remove_from_followers
    @account.followers_for_local_distribution.reorder(nil).find_each do |follower|
      FeedManager.instance.unpush_from_home(follower, @status)
    end
  end

  def remove_from_lists
    @account.lists_for_local_distribution.select(:id, :account_id).reorder(nil).find_each do |list|
      FeedManager.instance.unpush_from_list(list, @status)
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

    target_accounts = (@mentions.map(&:account).reject(&:local?) + @reblogs.map(&:account).reject(&:local?))
    target_accounts << @status.reblog.account if @status.reblog? && !@status.reblog.account.local?
    target_accounts.uniq!(&:id)

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

    relay! if relayable?
  end

  def relayable?
    @status.public_visibility?
  end

  def relay!
    ActivityPub::DeliveryWorker.push_bulk(Relay.enabled.pluck(:inbox_url)) do |inbox_url|
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
      RemoveStatusService.new.call(reblog, original_removed: true)
    end
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

  def remove_from_media
    return unless @status.public_visibility?

    Redis.current.publish('timeline:public:media', @payload)
    Redis.current.publish('timeline:public:local:media', @payload) if @status.local?
  end

  def remove_from_direct
    @mentions.each do |mention|
      Redis.current.publish("timeline:direct:#{mention.account.id}", @payload) if mention.account.local?
    end
    Redis.current.publish("timeline:direct:#{@account.id}", @payload) if @account.local?
  end

  def redis
    Redis.current
  end
end
