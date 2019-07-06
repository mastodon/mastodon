# frozen_string_literal: true

class Pubsubhubbub::ConfirmationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', retry: false

  def perform(subscription_id, mode, secret = nil, lease_seconds = nil); end
end
