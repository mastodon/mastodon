# frozen_string_literal: true

class Scheduler::TrendingTagsScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    Trends.refresh!
  end
end
