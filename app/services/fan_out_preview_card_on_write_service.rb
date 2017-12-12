# frozen_string_literal: true

class FanOutPreviewCardOnWriteService < BaseService
  def call(status)
    return if status.preview_cards.none?

    render_payload(status)

    deliver_to_self(status) if status.account.local?

    if status.direct_visibility?
      deliver_to_mentioned_followers(status)
    else
      deliver_to_followers(status)
      deliver_to_lists(status)
    end

    return if status.account.silenced? || !status.public_visibility? || status.reblog?

    deliver_to_hashtags(status)

    return if status.reply? && status.in_reply_to_account_id != status.account_id

    deliver_to_public(status)
  end

  private

  def deliver_to_self(status)
    Rails.logger.debug "Delivering a preview card for status #{status.id} to author"
    if FeedManager.instance.can_push_preview_card_to_home?(status.account, status)
      Redis.current.publish("timeline:#{status.account.id}:preview_card", @payload)
    end
  end

  def deliver_to_followers(status)
    Rails.logger.debug "Delivering a preview card for status #{status.id} to followers"

    status.account.followers.where(domain: nil).joins(:user).where('users.current_sign_in_at > ?', 14.days.ago).select(:id).reorder(nil).find_in_batches do |followers|

      followers.select! do |follower|
        FeedManager.instance.can_push_preview_card_to_home?(follower, status) &&
          !FeedManager.instance.filter?(:home, status, follower)
      end

      Redis.current.pipelined do
        followers.each do |follower|
          Redis.current.publish("timeline:#{follower.id}:preview_card", @payload)
        end
      end
    end
  end

  def deliver_to_lists(status)
    Rails.logger.debug "Delivering a preview card for status #{status.id} to lists"

    status.account.lists.joins(account: :user).where('users.current_sign_in_at > ?', 14.days.ago).reorder(nil).find_in_batches do |lists|
      lists.select! do |list|
        # Note: Lists are a variation of home, so the filtering rules
        # of home apply to both
        FeedManager.instance.can_push_preview_card_to_list?(list, status) &&
          !FeedManager.instance.filter?(:home, status, list.account)
      end

      Redis.current.pipelined do
        lists.each do |list|
          Redis.current.publish("timeline:list:#{list.id}:preview_card", @payload)
        end
      end
    end
  end

  def deliver_to_mentioned_followers(status)
    Rails.logger.debug "Delivering a preview card for status #{status.id} to mentioned followers"

    accounts = status.mentions
                     .includes(:account)
                     .lazy
                     .map { |mention| mention.account }
                     .select do |account|
      FeedManager.instance.can_push_preview_card_to_home?(account, status) ||
        account.local? || account.following?(status.account) ||
        !FeedManager.instance.filter?(:home, status, mention.account_id)
    end

    accounts_a = accounts.to_a

    Redis.current.pipelined do
      accounts_a.each do |account|
        Redis.current.publish("timeline:#{account.id}:preview_card", @payload)
      end
    end
  end

  def render_payload(status)
    @payload = Oj.dump(ActiveModelSerializers::SerializableResource.new(
      status,
      serializer: Streaming::CardSerializer
    ).as_json)
  end

  def deliver_to_hashtags(status)
    Rails.logger.debug "Delivering a preview card for status #{status.id} to hashtags"

    hashtags = status.tags.pluck(:name)

    Redis.current.pipelined do
      hashtags.each do |hashtag|
        Redis.current.publish("timeline:hashtag:#{hashtag}:preview_card", @payload)
        if status.local?
          Redis.current.publish("timeline:hashtag:#{hashtag}:local:preview_card", @payload)
        end
      end
    end
  end

  def deliver_to_public(status)
    Rails.logger.debug "Delivering a preview card for status #{status.id} to public timeline"

    Redis.current.publish('timeline:public:preview_card', @payload)
    Redis.current.publish('timeline:public:local:preview_card', @payload) if status.local?
  end
end
