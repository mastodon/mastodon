# frozen_string_literal: true
require 'sidekiq-scheduler'

class Scheduler::TrendTagsUpdateScheduler
  include Sidekiq::Worker

  def perform
    StatusesTag.update_trend_tags
  end
end
