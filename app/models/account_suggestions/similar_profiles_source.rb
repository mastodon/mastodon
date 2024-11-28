# frozen_string_literal: true

class AccountSuggestions::SimilarProfilesSource < AccountSuggestions::Source
  class QueryBuilder < AccountSearchService::QueryBuilder
    def must_clauses
      [
        {
          more_like_this: {
            fields: %w(text text.stemmed),
            like: @query.map { |id| { _index: 'accounts', _id: id } },
          },
        },

        {
          term: {
            properties: 'discoverable',
          },
        },
      ]
    end

    def must_not_clauses
      [
        {
          terms: {
            id: following_ids,
          },
        },

        {
          term: {
            properties: 'bot',
          },
        },
      ]
    end

    def should_clauses
      {
        term: {
          properties: {
            value: 'verified',
            boost: 2,
          },
        },
      }
    end
  end

  def get(account, limit: DEFAULT_LIMIT)
    recently_followed_account_ids = account.active_relationships.recent.limit(5).pluck(:target_account_id)

    if Chewy.enabled? && !recently_followed_account_ids.empty?
      ids_from_es = QueryBuilder.new(recently_followed_account_ids, account).build.limit(limit).hits.pluck('_id').map(&:to_i)
      base_account_scope(account).where(id: ids_from_es).pluck(:id).zip([key].cycle)
    else
      []
    end
  rescue Faraday::ConnectionFailed
    []
  end

  private

  def key
    :similar_to_recently_followed
  end
end
