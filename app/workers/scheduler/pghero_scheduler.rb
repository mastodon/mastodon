# frozen_string_literal: true

class Scheduler::PgheroScheduler
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, retry: 0

  def perform
    PgHero.capture_space_stats
  end
end
