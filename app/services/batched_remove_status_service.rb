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
    @json_payloads         = statuses.map { |s| [s.id, Oj.dump(event: :delete, payload: s.id.to_s)] }.to_h
    @activity_xml          = {}

    # Ensure that rendered XML reflects destroyed state
    statuses.each(&:destroy)

    # Batch by source account
    statuses.group_by(&:account_id).each_value do |account_statuses|
      account = account_statuses.first.account

      unpush_from_home_timelines(account, account_statuses)
      unpush_from_list_timelines(account, account_statuses)

      batch_stream_entries(account, account_statuses) if account.local?
    end

    # Cannot be batched
    statuses.each do |status|
      unpush_from_public_timelines(status)
      unpush_from_direct_timelines(status) if status.direct_visibility?
      batch_salmon_slaps(status) if status.local?
    end

    Pubsubhubbub::RawDistributionWorker.push_bulk(@stream_entry_batches) { |batch| batch }
    NotificationWorker.push_bulk(@salmon_batches) { |batch| batch }
  end

  private

  def batch_stream_entries(account, statuses)
    statuses.each do |status|
      @stream_entry_batches << [build_xml(status.stream_entry), account.id]
    end
  end

  def unpush_from_home_timelines(account, statuses)
    recipients = account.followers.local.to_a

    recipients << account if account.local?

    recipients.each do |follower|
      statuses.each do |status|
        FeedManager.instance.unpush_from_home(follower, status)
      end
    end
  end

  def unpush_from_list_timelines(account, statuses)
    account.lists.select(:id, :account_id).each do |list|
      statuses.each do |status|
        FeedManager.instance.unpush_from_list(list, status)
      end
    end
  end

  def unpush_from_public_timelines(status)
    return unless status.public_visibility?

    payload = @json_payloads[status.id]

    redis.pipelined do
      redis.publish('timeline:public', payload)
      redis.publish('timeline:public:local', payload) if status.local?

      if status.media_attachments.any?
        redis.publish('timeline:public:media', payload)
        redis.publish('timeline:public:local:media', payload) if status.local?
      end

      @tags[status.id].each do |hashtag|
        redis.publish("timeline:hashtag:#{hashtag}", payload)
        redis.publish("timeline:hashtag:#{hashtag}:local", payload) if status.local?
      end
    end
  end

  def unpush_from_direct_timelines(status)
    payload = @json_payloads[status.id]
    redis.pipelined do
      @mentions[status.id].each do |mention|
        redis.publish("timeline:direct:#{mention.account.id}", payload) if mention.account.local?
      end
      redis.publish("timeline:direct:#{status.account.id}", payload) if status.account.local?
    end
  end

  def batch_salmon_slaps(status)
    return if @mentions[status.id].empty?

    recipients = @mentions[status.id].map(&:account).reject(&:local?).select(&:ostatus?).uniq(&:domain).map(&:id)

    recipients.each do |recipient_id|
      @salmon_batches << [build_xml(status.stream_entry), status.account_id, recipient_id]
    end
  end

  def redis
    Redis.current
  end

  def build_xml(stream_entry)
    return @activity_xml[stream_entry.id] if @activity_xml.key?(stream_entry.id)

    @activity_xml[stream_entry.id] = stream_entry_to_xml(stream_entry)
  end
end
