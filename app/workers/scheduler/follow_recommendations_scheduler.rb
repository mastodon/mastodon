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

    fallback_recommendations = FollowRecommendation.order(rank: :desc).limit(SET_SIZE)

    Trends.available_locales.each do |locale|
      recommendations = if AccountSummary.safe.filtered.localized(locale).exists? # We can skip the work if no accounts with that language exist
                          FollowRecommendation.localized(locale).order(rank: :desc).limit(SET_SIZE).map { |recommendation| [recommendation.rank, recommendation.account_id] }
                        else
                          []
                        end

      # Use language-agnostic results if there are not enough language-specific ones
      missing = SET_SIZE - recommendations.size

      if missing.positive? && fallback_recommendations.size.positive?
        max_fallback_rank = fallback_recommendations.first.rank || 0

        # Language-specific results should be above language-agnostic ones,
        # otherwise language-agnostic ones will always overshadow them
        recommendations.map! { |(rank, account_id)| [rank + max_fallback_rank, account_id] }

        added = 0

        fallback_recommendations.each do |recommendation|
          next if recommendations.any? { |(_, account_id)| account_id == recommendation.account_id }

          recommendations << [recommendation.rank, recommendation.account_id]
          added += 1

          break if added >= missing
        end
      end

      redis.multi do |multi|
        multi.del(key(locale))
        multi.zadd(key(locale), recommendations)
      end
    end
  end

  private

  def key(locale)
    "follow_recommendations:#{locale}"
  end
end
