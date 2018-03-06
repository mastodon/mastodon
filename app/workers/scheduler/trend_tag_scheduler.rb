# frozen_string_literal: true
require 'sidekiq-scheduler'

class Scheduler::TrendTagScheduler
  include Sidekiq::Worker

  def perform
    StatusesTag.calc_trend
    Redis.current.publish('commands', '{"event": "trend_tags"}')
  end
end
