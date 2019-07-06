# frozen_string_literal: true

class NotificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', retry: 5

  def perform(xml, source_account_id, target_account_id); end
end
