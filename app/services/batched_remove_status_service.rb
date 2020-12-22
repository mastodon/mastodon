# frozen_string_literal: true

class BatchedRemoveStatusService < BaseService
  include Redisable

  # Delete multiple statuses and reblogs of them as efficiently as possible
  # @param [Enumerable<Status>] statuses An array of statuses
  # @param [Hash] options
  # @option [Boolean] :skip_side_effects Do not modify feeds and send updates to streaming API
  def call(statuses, **options)
    ActiveRecord::Associations::Preloader.new.preload(statuses, options[:skip_side_effects] ? :reblogs : [:account, reblogs: :account])

    statuses_and_reblogs = statuses.flat_map { |status| [status] + status.reblogs }

    # The conversations for direct visibility statuses also need
    # to be manually updated. This part is not efficient but we
    # rely on direct visibility statuses being relatively rare.
    statuses_with_account_conversations = statuses.select(&:direct_visibility?)

    ActiveRecord::Associations::Preloader.new.preload(statuses_with_account_conversations, [mentions: :account])

    statuses_with_account_conversations.each do |status|
      status.send(:unlink_from_conversations)
    end

    # We do not batch all deletes into one to avoid having a long-running
    # transaction lock the database, but we use the delete method instead
    # of destroy to avoid all callbacks. We rely on foreign keys to
    # cascade the delete faster without loading the associations.
    statuses_and_reblogs.each(&:delete)

    # Since we skipped all callbacks, we also need to manually
    # deindex the statuses
    Chewy.strategy.current.update(StatusesIndex, statuses_and_reblogs)

    return if options[:skip_side_effects]

    ActiveRecord::Associations::Preloader.new.preload(statuses_and_reblogs, :tags)

    @tags          = statuses_and_reblogs.each_with_object({}) { |s, h| h[s.id] = s.tags.map { |tag| tag.name.mb_chars.downcase } }
    @json_payloads = statuses_and_reblogs.each_with_object({}) { |s, h| h[s.id] = Oj.dump(event: :delete, payload: s.id.to_s) }

    # Batch by source account
    statuses_and_reblogs.group_by(&:account_id).each_value do |account_statuses|
      account = account_statuses.first.account

      next unless account

      unpush_from_home_timelines(account, account_statuses)
      unpush_from_list_timelines(account, account_statuses)
    end

    # Cannot be batched
    redis.pipelined do
      statuses_and_reblogs.each do |status|
        unpush_from_public_timelines(status)
      end
    end
  end

  private

  def unpush_from_home_timelines(account, statuses)
    account.followers_for_local_distribution.includes(:user).reorder(nil).find_each do |follower|
      statuses.each do |status|
        FeedManager.instance.unpush_from_home(follower, status)
      end
    end

    return unless account.local?

    statuses.each do |status|
      FeedManager.instance.unpush_from_home(account, status)
    end
  end

  def unpush_from_list_timelines(account, statuses)
    account.lists_for_local_distribution.select(:id, :account_id).includes(account: :user).reorder(nil).find_each do |list|
      statuses.each do |status|
        FeedManager.instance.unpush_from_list(list, status)
      end
    end
  end

  def unpush_from_public_timelines(status)
    return unless status.public_visibility?

    payload = @json_payloads[status.id]

    redis.publish('timeline:public', payload)
    redis.publish(status.local? ? 'timeline:public:local' : 'timeline:public:remote', payload)

    if status.media_attachments.any?
      redis.publish('timeline:public:media', payload)
      redis.publish(status.local? ? 'timeline:public:local:media' : 'timeline:public:remote:media', payload)
    end

    @tags[status.id].each do |hashtag|
      redis.publish("timeline:hashtag:#{hashtag}", payload)
      redis.publish("timeline:hashtag:#{hashtag}:local", payload) if status.local?
    end
  end
end
