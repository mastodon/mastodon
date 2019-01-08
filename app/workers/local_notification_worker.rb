# frozen_string_literal: true

class LocalNotificationWorker
  include Sidekiq::Worker

  def perform(mention_id)
    mention = Mention.find(mention_id)
    NotifyService.new.call(mention.account, mention)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
