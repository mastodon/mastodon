# frozen_string_literal: true

class Scheduler::Trends::ReviewNotificationsScheduler < ApplicationWorker
  sidekiq_options retry: 0

  def perform
    Trends.request_review!
  end
end
