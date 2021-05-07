# frozen_string_literal: true

class AccountSuggestions
  SOURCES = [
    AccountSuggestions::SettingSource,
    AccountSuggestions::PastInteractionsSource,
    AccountSuggestions::GlobalSource,
  ].freeze

  def self.get(account, limit)
    SOURCES.each_with_object([]) do |source_class, suggestions|
      source_suggestions = source_class.new.get(
        account,
        skip_account_ids: suggestions.map(&:account_id),
        limit: limit - suggestions.size
      )

      suggestions.concat(source_suggestions)
    end
  end

  def self.remove(account, target_account_id)
    SOURCES.each do |source_class|
      source = source_class.new
      source.remove(account, target_account_id)
    end
  end
end
