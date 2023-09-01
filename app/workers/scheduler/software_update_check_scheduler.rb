# frozen_string_literal: true

class Scheduler::SoftwareUpdateCheckScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.hour.to_i

  def perform
    SoftwareUpdateCheckService.new.call
  end
end
