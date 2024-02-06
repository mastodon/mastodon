# frozen_string_literal: true

class Scheduler::Trends::RefreshScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 30.minutes.to_i

  def perform
    Trends.refresh!
  end
end
