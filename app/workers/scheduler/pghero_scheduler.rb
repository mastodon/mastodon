# frozen_string_literal: true

class Scheduler::PgheroScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform
    PgHero.capture_space_stats
  end
end
