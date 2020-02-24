# frozen_string_literal: true

class BatchedRemoveStatusService < BaseService
  include StreamEntryRenderer
  include Redisable

  # Delete given statuses and reblogs of them
  # Dispatch PuSH updates of the deleted statuses, but only local ones
  # Dispatch Salmon deletes, unique per domain, of the deleted statuses, but only local ones
  # Remove statuses from home feeds
  # Push delete events to streaming API for home feeds and public feeds
  # @param [Status] statuses A preferably batched array of statuses
  # @param [Hash] options
  # @option [Boolean] :skip_side_effects
  def call(statuses, **options)
    statuses = Status.where(id: statuses.map(&:id)).includes(:account, :stream_entry).flat_map { |status| [status] + status.reblogs.includes(:account, :stream_entry).to_a }

    @mentions = statuses.each_with_object({}) { |s, h| h[s.id] = s.active_mentions.includes(:account).to_a }
    @tags     = statuses.each_with_object({}) { |s, h| h[s.id] = s.tags.pluck(:name) }

    @stream_entry_batches  = []
    @salmon_batches        = []
    @json_payloads         = statuses.each_with_object({}) { |s, h| h[s.id] = Oj.dump(event: :delete, payload: s.id.to_s) }
    @activity_xml          = {}

    # Ensure that rendered XML reflects destroyed state
    statuses.each do |status|
      status.mark_for_mass_destruction!
      status.destroy
    end

    return if options[:skip_side_effects]

    # Batch by source account
    statuses.group_by(&:account_id).each_value do |account_statuses|
      account = account_statuses.first.account

      next unless account

      unpush_from_home_timelines(account, account_statuses)
      unpush_from_list_timelines(account, account_statuses)

      batch_stream_entries(account, account_statuses) if account.local?
    end

    # Cannot be batched
    statuses.each do |status|
      unpush_from_public_timelines(status)
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
    recipients = account.followers_for_local_distribution.to_a

    recipients << account if account.local?

    recipients.each do |follower|
      statuses.each do |status|
        FeedManager.instance.unpush_from_home(follower, status)
      end
    end
  end

  def unpush_from_list_timelines(account, statuses)
    account.lists_for_local_distribution.select(:id, :account_id).each do |list|
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

  def batch_salmon_slaps(status)
    return if @mentions[status.id].empty?

    recipients = @mentions[status.id].map(&:account).reject(&:local?).select(&:ostatus?).uniq(&:domain).map(&:id)

    recipients.each do |recipient_id|
      @salmon_batches << [build_xml(status.stream_entry), status.account_id, recipient_id]
    end
  end

  def build_xml(stream_entry)
    return @activity_xml[stream_entry.id] if @activity_xml.key?(stream_entry.id)

    @activity_xml[stream_entry.id] = stream_entry_to_xml(stream_entry)
  end
end
