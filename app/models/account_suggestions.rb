# frozen_string_literal: true

class AccountSuggestions
  class Suggestion < ActiveModelSerializers::Model
    attributes :account, :source
  end

  def self.get(account, limit)
    suggestions = PotentialFriendshipTracker.get(account, limit).map { |target_account| Suggestion.new(account: target_account, source: :past_interaction) }
    suggestions.concat(FollowRecommendation.get(account, limit - suggestions.size, suggestions.map { |suggestion| suggestion.account.id }).map { |target_account| Suggestion.new(account: target_account, source: :global) }) if suggestions.size < limit
    suggestions
  end

  def self.remove(account, target_account_id)
    PotentialFriendshipTracker.remove(account.id, target_account_id)
  end
end
