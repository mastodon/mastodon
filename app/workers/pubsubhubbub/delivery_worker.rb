# frozen_string_literal: true

class Pubsubhubbub::DeliveryWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', retry: 3, dead: false

  def perform(subscription_id, payload); end
end
