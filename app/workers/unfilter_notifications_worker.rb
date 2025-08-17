# frozen_string_literal: true

class UnfilterNotificationsWorker
  include Sidekiq::Worker
  include Redisable

  def perform(account_id, from_account_id)
    @from_account = Account.find_by(id: from_account_id)
    @recipient    = Account.find_by(id: account_id)

    return if @from_account.nil? || @recipient.nil?

    push_to_conversations!
    unfilter_notifications!
    decrement_worker_count!
  end

  private

  def push_to_conversations!
    notifications_with_private_mentions.reorder(nil).find_each(order: :desc) { |notification| AccountConversation.add_status(@recipient, notification.target_status) }
  end

  def unfilter_notifications!
    filtered_notifications.in_batches.update_all(filtered: false)
  end

  def filtered_notifications
    Notification.where(account: @recipient, from_account: @from_account, filtered: true)
  end

  def notifications_with_private_mentions
    filtered_notifications.where(type: :mention).joins(mention: :status).merge(Status.where(visibility: :direct)).includes(mention: :status)
  end

  def decrement_worker_count!
    value = redis.decr("notification_unfilter_jobs:#{@recipient.id}")
    push_streaming_event! if value <= 0 && subscribed_to_streaming_api?
  end

  def push_streaming_event!
    redis.publish("timeline:#{@recipient.id}:notifications", Oj.dump(event: :notifications_merged, payload: '1'))
  end

  def subscribed_to_streaming_api?
    redis.exists?("subscribed:timeline:#{@recipient.id}") || redis.exists?("subscribed:timeline:#{@recipient.id}:notifications")
  end
end
