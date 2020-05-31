# frozen_string_literal: true

class Pubsubhubbub::RawDistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(xml, source_account_id); end
end
