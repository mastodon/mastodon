# frozen_string_literal: true

class Pubsubhubbub::SubscribeWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', retry: 10, unique: :until_executed, dead: false

  def perform(account_id); end
end
