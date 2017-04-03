# frozen_string_literal: true

class RegenerationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', backtrace: true

  def perform(account_id, timeline_type)
    PrecomputeFeedService.new.call(timeline_type, Account.find(account_id))
  end
end
