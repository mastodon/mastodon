# frozen_string_literal: true

module Account::Search
  extend ActiveSupport::Concern

  def searchable_text
    PlainTextFormatter.new(note, local?).to_s if discoverable?
  end

  def searchable_properties
    [].tap do |properties|
      properties << 'bot' if bot?
      properties << 'verified' if fields.any?(&:verified?)
      properties << 'discoverable' if discoverable?
    end
  end

  class_methods do
    def search_for(terms, limit: AccountSearchQuery::DEFAULT_LIMIT, offset: 0)
      AccountSearchQuery.new(terms:, limit:, offset:).search
    end

    def advanced_search_for(terms, account, limit: AccountSearchQuery::DEFAULT_LIMIT, following: false, offset: 0)
      AccountSearchQuery.new(terms:, limit:, offset:).advanced_search(account, following: following)
    end
  end
end
