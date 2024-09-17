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

  DEFAULT_LIMIT = 10

  class_methods do
    def search_for(terms, limit: DEFAULT_LIMIT, offset: 0)
      AccountSearchQuery.search_for(terms, limit: limit, offset: offset)
    end

    def advanced_search_for(terms, account, limit: DEFAULT_LIMIT, following: false, offset: 0)
      AccountSearchQuery.advanced_search_for(terms, account, limit: limit, following: following, offset: offset)
    end
  end
end
