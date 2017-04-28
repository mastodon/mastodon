# frozen_string_literal: true

class DailyWorker
  include Sidekiq::Worker

  def perform
    MastodonTasksService.daily
  end
end
