# frozen_string_literal: true

class AccountsIndex < Chewy::Index
  settings index: { refresh_interval: '5m' }, analysis: {
    analyzer: {
      content: {
        tokenizer: 'ik_max_word',
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

  index_scope ::Account.searchable.includes(:account_stat), delete_if: ->(account) { account.destroyed? || !account.searchable? }

  root date_detection: false do
    field :id, type: 'long'

    field :display_name, type: 'text', analyzer: 'content' do
      field :edge_ngram, type: 'text', analyzer: 'edge_ngram', search_analyzer: 'content'
    end

    field :acct, type: 'text', analyzer: 'content', value: ->(account) { [account.username, account.domain].compact.join('@') } do
      field :edge_ngram, type: 'text', analyzer: 'edge_ngram', search_analyzer: 'content'
    end

    field :following_count, type: 'long', value: ->(account) { account.following.local.count }
    field :followers_count, type: 'long', value: ->(account) { account.followers.local.count }
    field :last_status_at, type: 'date', value: ->(account) { account.last_status_at || account.created_at }
  end
end
