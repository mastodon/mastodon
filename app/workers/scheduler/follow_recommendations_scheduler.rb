# frozen_string_literal: true

class Scheduler::FollowRecommendationsScheduler
  include Sidekiq::Worker
  include Redisable

  sidekiq_options retry: 0

  # The maximum number of accounts that can be requested in one page from the
  # API is 80, and the suggestions API does not allow pagination. This number
  # leaves some room for accounts being filtered during live access
  SET_SIZE = 100

  def perform
    # Maintaining a materialized view speeds-up subsequent queries significantly
    AccountSummary.refresh
    FollowRecommendation.refresh

    fallback_recommendations = FollowRecommendation.order(rank: :desc).limit(SET_SIZE).index_by(&:account_id)

    I18n.available_locales.each do |locale|
      recommendations = begin
        if AccountSummary.safe.filtered.localized(locale).exists? # We can skip the work if no accounts with that language exist
          FollowRecommendation.localized(locale).order(rank: :desc).limit(SET_SIZE).index_by(&:account_id)
        else
          {}
        end
      end

      # Use language-agnostic results if there are not enough language-specific ones
      missing = SET_SIZE - recommendations.keys.size

      if missing.positive?
        added = 0

        # Avoid duplicate results
        fallback_recommendations.each_value do |recommendation|
          next if recommendations.key?(recommendation.account_id)

          recommendations[recommendation.account_id] = recommendation
          added += 1

          break if added >= missing
        end
      end

      redis.pipelined do
        redis.del(key(locale))

        recommendations.each_value do |recommendation|
          redis.zadd(key(locale), recommendation.rank, recommendation.account_id)
        end
      end
    end
  end

  private

  def key(locale)
    "follow_recommendations:#{locale}"
  end
end
