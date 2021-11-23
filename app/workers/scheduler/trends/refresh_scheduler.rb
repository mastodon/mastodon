# frozen_string_literal: true

class Scheduler::Trends::RefreshScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    Trends.refresh!
  end
end
