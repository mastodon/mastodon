# frozen_string_literal: true

class BatchedRemoveStatusService < BaseService
  include StreamEntryRenderer

  # Delete given statuses and reblogs of them
  # Dispatch PuSH updates of the deleted statuses, but only local ones
  # Dispatch Salmon deletes, unique per domain, of the deleted statuses, but only local ones
  # Remove statuses from home feeds
  # Push delete events to streaming API for home feeds and public feeds
  # @param [Status] statuses A preferably batched array of statuses
  def call(statuses)
    statuses = Status.where(id: statuses.map(&:id)).includes(:account, :stream_entry).flat_map { |status| [status] + status.reblogs.includes(:account, :stream_entry).to_a }

    @mentions = statuses.map { |s| [s.id, s.mentions.includes(:account).to_a] }.to_h
    @tags     = statuses.map { |s| [s.id, s.tags.pluck(:name)] }.to_h

    @stream_entry_batches  = []
    @salmon_batches        = []
    @activity_json_batches = []
    @json_payloads         = statuses.map { |s| [s.id, Oj.dump(event: :delete, payload: s.id)] }.to_h
    @activity_json         = {}
    @activity_xml          = {}

    # Ensure that rendered XML reflects destroyed state
    statuses.each(&:destroy)

    # Batch by source account
    statuses.group_by(&:account_id).each do |_, account_statuses|
      account = account_statuses.first.account

      unpush_from_home_timelines(account_statuses)

      if account.local?
        batch_stream_entries(account, account_statuses)
        batch_activity_json(account, account_statuses)
      end
    end

    # Cannot be batched
    statuses.each do |status|
      unpush_from_public_timelines(status)
      batch_salmon_slaps(status) if status.local?
    end

    Pubsubhubbub::RawDistributionWorker.push_bulk(@stream_entry_batches) { |batch| batch }
    NotificationWorker.push_bulk(@salmon_batches) { |batch| batch }
    ActivityPub::DeliveryWorker.push_bulk(@activity_json_batches) { |batch| batch }
  end

  private

  def batch_stream_entries(account, statuses)
    statuses.each do |status|
      @stream_entry_batches << [build_xml(status.stream_entry), account.id]
    end
  end

  def batch_activity_json(account, statuses)
    account.followers.inboxes.each do |inbox_url|
      statuses.each do |status|
        @activity_json_batches << [build_json(status), account.id, inbox_url]
      end
    end

    statuses.each do |status|
      other_recipients = (status.mentions + status.reblogs).map(&:account).reject(&:local?).select(&:activitypub?).uniq(&:id)

      other_recipients.each do |target_account|
        @activity_json_batches << [build_json(status), account.id, target_account.inbox_url]
      end
    end
  end

  def unpush_from_home_timelines(statuses)
    account    = statuses.first.account
    recipients = account.followers.local.pluck(:id)

    recipients << account.id if account.local?

    recipients.each do |follower_id|
      unpush(follower_id, statuses)
    end
  end

  def unpush_from_public_timelines(status)
    payload = @json_payloads[status.id]

    redis.pipelined do
      redis.publish('timeline:public', payload)
      redis.publish('timeline:public:local', payload) if status.local?

      @tags[status.id].each do |hashtag|
        redis.publish("timeline:hashtag:#{hashtag}", payload)
        redis.publish("timeline:hashtag:#{hashtag}:local", payload) if status.local?
      end
    end
  end

  def batch_salmon_slaps(status)
    return if @mentions[status.id].empty?

    recipients = @mentions[status.id].map(&:account).reject(&:local?).select(&:ostatus?).uniq(&:domain).map(&:id)

    recipients.each do |recipient_id|
      @salmon_batches << [build_xml(status.stream_entry), status.account_id, recipient_id]
    end
  end

  def unpush(follower_id, statuses)
    key = FeedManager.instance.key(:home, follower_id)

    originals = statuses.reject(&:reblog?)
    reblogs   = statuses.select(&:reblog?)

    # Quickly remove all originals
    redis.pipelined do
      originals.each do |status|
        redis.zremrangebyscore(key, status.id, status.id)
        redis.publish("timeline:#{follower_id}", @json_payloads[status.id])
      end
    end

    # For reblogs, re-add original status to feed, unless the reblog
    # was not in the feed in the first place
    reblogs.each do |status|
      redis.zadd(key, status.reblog_of_id, status.reblog_of_id) unless redis.zscore(key, status.reblog_of_id).nil?
      redis.publish("timeline:#{follower_id}", @json_payloads[status.id])
    end
  end

  def redis
    Redis.current
  end

  def build_json(status)
    return @activity_json[status.id] if @activity_json.key?(status.id)

    @activity_json[status.id] = sign_json(status, ActiveModelSerializers::SerializableResource.new(
      status,
      serializer: status.reblog? ? ActivityPub::UndoAnnounceSerializer : ActivityPub::DeleteSerializer,
      adapter: ActivityPub::Adapter
    ).as_json)
  end

  def build_xml(stream_entry)
    return @activity_xml[stream_entry.id] if @activity_xml.key?(stream_entry.id)

    @activity_xml[stream_entry.id] = stream_entry_to_xml(stream_entry)
  end

  def sign_json(status, json)
    Oj.dump(ActivityPub::LinkedDataSignature.new(json).sign!(status.account))
  end
end
