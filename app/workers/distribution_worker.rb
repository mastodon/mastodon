# frozen_string_literal: true

class DistributionWorker
  include Sidekiq::Worker

  def perform(status_id, activitypub_audience = nil)
    status = Status.find(status_id)
    original_id = status.reblog? ? status_id : status.reblog_of_id

    begin
      Redis.current.subscribe_with_timeout 1, "preview_card_fetch:#{original_id}:progress" do |on|
        on.message { Redis.current.unsubscribe }
        on.subscribe { Redis.current.unsubscribe unless Redis.current.exists "preview_card_fetch:#{original_id}:pending" }
      end
    rescue Redis::TimeoutError
      Rails.logger.debug "preview card timeout occurred when distributing status #{status_id}"
    end

    create_reblog_notification status if status.reblog?
    create_mention_notifications status, activitypub_audience

    FanOutOnWriteService.new.call(status)
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def create_reblog_notification(reblog)
    reblogged_status = reblog.reblog

    if reblogged_status.account.local?
      NotifyService.new.call(reblogged_status.account, reblog)
    end
  end

  def create_mention_notifications(status, activitypub_audience)
    status.mentions.includes(:account).references(:account).merge(Account.local).each do |mention|
      next if activitypub_audience&.exclude? ActivityPub::TagManager.instance.uri_for(mention.account)
      NotifyService.new.call(mention.account, mention)
    end
  end
end
