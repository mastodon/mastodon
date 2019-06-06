# frozen_string_literal: true

class ActivityPub::LowPriorityDeliveryWorker < ActivityPub::DeliveryWorker
  sidekiq_options queue: 'pull', retry: 8, dead: false
end
