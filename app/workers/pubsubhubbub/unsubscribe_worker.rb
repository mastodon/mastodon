# frozen_string_literal: true

class Pubsubhubbub::UnsubscribeWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', retry: false, unique: :until_executed, dead: false

  def perform(account_id); end
end
