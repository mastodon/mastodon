# frozen_string_literal: true

class EmailDistributionWorker
  include Sidekiq::Worker
  include Redisable

  sidekiq_options lock: :until_executed, lock_ttl: 1.day.to_i

  def perform(account_id)
    return unless Mastodon::Feature.email_subscriptions_enabled?

    @account = Account.find(account_id)

    return unless @account.user_can?(:manage_email_subscriptions) && @account.user_email_subscriptions_enabled?

    with_redis do |redis|
      @status_ids = redis.smembers("email_subscriptions:#{account_id}:next_batch")
      redis.srem("email_subscriptions:#{account_id}:next_batch", @status_ids)
    end

    return if @account.email_subscriptions.confirmed.empty? || @status_ids.empty?

    statuses = Status.without_replies
      .without_reblogs
      .public_visibility
      .where(id: @status_ids)
      .to_a

    return if statuses.empty?

    @account.email_subscriptions.confirmed.find_each do |email_subscription|
      EmailSubscriptionMailer.with(subscription: email_subscription).notification(statuses).deliver_later
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
