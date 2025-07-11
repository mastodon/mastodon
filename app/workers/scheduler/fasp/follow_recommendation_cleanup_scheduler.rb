# frozen_string_literal: true

class Scheduler::Fasp::FollowRecommendationCleanupScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform
    return unless Mastodon::Feature.fasp_enabled?

    Fasp::FollowRecommendation.outdated.delete_all
  end
end
