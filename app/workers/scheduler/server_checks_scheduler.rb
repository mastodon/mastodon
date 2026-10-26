# frozen_string_literal: true

class Scheduler::ServerChecksScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.hour.to_i

  def perform
    Admin::ServerCheck.checks.each do |check|
      next unless check.async?
      next if check.running? && check.updated_at&.>(1.hour.ago)

      check.running!

      check.run do |err|
        Sidekiq.logger.error("Error running ServerCheck '#{check.key}': #{err.message}")
      end

      check.save
    end
  end
end
