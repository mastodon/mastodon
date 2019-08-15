# frozen_string_literal: true

class AccountsIndex < Chewy::Index
  settings index: { refresh_interval: '5m' }, analysis: {
    analyzer: {
      content: {
        tokenizer: 'whitespace',
        filter: %w(lowercase asciifolding cjk_width),
      },

      edge_ngram: {
        tokenizer: 'edge_ngram',
        filter: %w(lowercase asciifolding cjk_width),
      },
    },

    tokenizer: {
      edge_ngram: {
        type: 'edge_ngram',
        min_gram: 1,
        max_gram: 15,
      },
    },
  }

  define_type ::Account.searchable.includes(:account_stat), delete_if: ->(account) { account.destroyed? || !account.searchable? } do
    root date_detection: false do
      field :id, type: 'long'
      field :display_name, type: 'text', analyzer: 'edge_ngram', search_analyzer: 'content'
      field :acct, type: 'text', analyzer: 'edge_ngram', search_analyzer: 'content', value: ->(account) { [account.username, account.domain].compact.join('@') }
      field :following_count, type: 'long', value: ->(account) { account.active_relationships.count }
      field :followers_count, type: 'long', value: ->(account) { account.passive_relationships.count }
      field :last_status_at, type: 'date', value: ->(account) { account.last_status_at || account.created_at }
    end
  end
end
