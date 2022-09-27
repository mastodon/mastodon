# frozen_string_literal: true

class ActivityPub::GroupDeliveryWorker < ActivityPub::DeliveryWorker
  sidekiq_options queue: 'push', retry: 16, dead: false

  private

  def actor_from_id(actor_id)
    Group.find(actor_id)
  end
end
