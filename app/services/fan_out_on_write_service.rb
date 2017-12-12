# frozen_string_literal: true

require 'sidekiq-bulk'

class FanOutOnWriteService < BaseService
  # Push a status into home and mentions feeds
  # @param [Status] status
  def call(status)
    raise Mastodon::RaceConditionError if status.visibility.nil?

    deliver_to_self(status) if status.account.local?

    if status.direct_visibility?
      deliver_to_mentioned_followers(status)
    else
      deliver_to_followers(status)
      deliver_to_lists(status)
    end

    if !status.account.silenced? && status.public_visibility? && !status.reblog?
      render_anonymous_payload(status)
      deliver_to_hashtags(status)

      if !status.reply? || status.in_reply_to_account_id == status.account_id
        deliver_to_public(status)
      end
    end

    deliver_preview_card(status)
  end

  private

  def deliver_to_self(status)
    Rails.logger.debug "Delivering status #{status.id} to author"
    FeedManager.instance.push_to_home(status.account, status)
  end

  def deliver_to_followers(status)
    Rails.logger.debug "Delivering status #{status.id} to followers"

    status.account.followers.where(domain: nil).joins(:user).where('users.current_sign_in_at > ?', 14.days.ago).select(:id).reorder(nil).find_in_batches do |followers|
      FeedInsertWorker.push_bulk(followers) do |follower|
        [status.id, follower.id, :home]
      end
    end
  end

  def deliver_to_lists(status)
    Rails.logger.debug "Delivering status #{status.id} to lists"

    status.account.lists.joins(account: :user).where('users.current_sign_in_at > ?', 14.days.ago).select(:id).reorder(nil).find_in_batches do |lists|
      FeedInsertWorker.push_bulk(lists) do |list|
        [status.id, list.id, :list]
      end
    end
  end

  def deliver_to_mentioned_followers(status)
    Rails.logger.debug "Delivering status #{status.id} to mentioned followers"

    status.mentions.includes(:account).each do |mention|
      mentioned_account = mention.account
      next if !mentioned_account.local? || !mentioned_account.following?(status.account) || FeedManager.instance.filter?(:home, status, mention.account_id)
      FeedManager.instance.push_to_home(mentioned_account, status)
    end
  end

  def render_anonymous_payload(status)
    @payload = Oj.dump(ActiveModelSerializers::SerializableResource.new(
      status,
      serializer: Streaming::UpdateSerializer,
      scope: nil,
      scope_name: :current_user
    ).as_json)
  end

  def deliver_to_hashtags(status)
    Rails.logger.debug "Delivering status #{status.id} to hashtags"

    status.tags.pluck(:name).each do |hashtag|
      Redis.current.publish("timeline:hashtag:#{hashtag}", @payload)
      Redis.current.publish("timeline:hashtag:#{hashtag}:local", @payload) if status.local?
    end
  end

  def deliver_to_public(status)
    Rails.logger.debug "Delivering status #{status.id} to public timeline"

    Redis.current.publish('timeline:public', @payload)
    Redis.current.publish('timeline:public:local', @payload) if status.local?
  end

  def deliver_preview_card(status)
    owner_id = status.reblog? ? status.reblog_of_id : status.id
    present_key = "preview_card_fetch:#{owner_id}:present"
    queue_key = "preview_card_fetch:#{owner_id}:queue"

    queued = Redis.current.watch present_key do
      next unless Redis.current.exists present_key

      Redis.current.multi do |multi|
        multi.sadd queue_key, status.id
      end
    end

    FanOutPreviewCardOnWriteService.new.call status if queued.nil?
  end
end
