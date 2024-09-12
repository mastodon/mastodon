# frozen_string_literal: true

class AccountSuggestions
  include DatabaseHelper

  SOURCES = [
    AccountSuggestions::SettingSource,
    AccountSuggestions::FriendsOfFriendsSource,
    AccountSuggestions::SimilarProfilesSource,
    AccountSuggestions::GlobalSource,
  ].freeze

  BATCH_SIZE = 40

  def initialize(account)
    @account = account
  end

  def get(limit, offset = 0)
    with_read_replica do
      account_ids_with_sources = Rails.cache.fetch("follow_recommendations/#{@account.id}", expires_in: 15.minutes) do
        SOURCES.flat_map { |klass| klass.new.get(@account, limit: BATCH_SIZE) }.each_with_object({}) do |(account_id, source), h|
          (h[account_id] ||= []).concat(Array(source).map(&:to_sym))
        end.to_a.shuffle
      end

      # The sources deliver accounts that haven't yet been followed, are not blocked,
      # and so on. Since we reset the cache on follows, blocks, and so on, we don't need
      # a complicated query on this end.

      account_ids  = account_ids_with_sources[offset, limit]
      accounts_map = Account.where(id: account_ids.map(&:first)).includes(:account_stat, :user).index_by(&:id)

      account_ids.filter_map do |(account_id, sources)|
        next unless accounts_map.key?(account_id)

        AccountSuggestions::Suggestion.new(
          account: accounts_map[account_id],
          sources: sources
        )
      end
    end
  end

  def remove(target_account_id)
    FollowRecommendationMute.create(account_id: @account.id, target_account_id: target_account_id)
  end
end
