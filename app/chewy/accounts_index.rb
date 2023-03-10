# frozen_string_literal: true

class AccountsIndex < Chewy::Index
  settings index: { refresh_interval: '30s' }, analysis: {
    filter: {
      english_stop: {
        type: 'stop',
        stopwords: '_english_',
      },
      english_stemmer: {
        type: 'stemmer',
        language: 'english',
      },
      english_possessive_stemmer: {
        type: 'stemmer',
        language: 'possessive_english',
      },
    },

    analyzer: {
      content: {
        tokenizer: 'whitespace',
        filter: %w(lowercase asciifolding cjk_width),
      },

      edge_ngram: {
        tokenizer: 'edge_ngram',
        filter: %w(lowercase asciifolding cjk_width),
      },

      text: {
        tokenizer: 'uax_url_email',
        filter: %w(
          english_possessive_stemmer
          lowercase
          asciifolding
          cjk_width
          english_stop
          english_stemmer
        ),
      },
    },

    tokenizer: {
      edge_ngram: {
        type: 'edge_ngram',
        min_gram: 1,
        max_gram: 15,
      },
    },

    normalizer: {
      tag: {
        type: 'custom',
        filter: %w(
          lowercase
          asciifolding
          cjk_width
        ),
      },
    },
  }

  index_scope ::Account.searchable.includes(:account_stat)

  root date_detection: false do
    field :id, type: 'long'

    field :display_name, type: 'text', analyzer: 'content' do
      field :edge_ngram, type: 'text', analyzer: 'edge_ngram', search_analyzer: 'content'
    end

    field :acct, type: 'text', analyzer: 'content', value: ->(account) { [account.username, account.domain].compact.join('@') } do
      field :edge_ngram, type: 'text', analyzer: 'edge_ngram', search_analyzer: 'content'
    end

    field :following_count, type: 'long', value: ->(account) { account.following_count }
    field :followers_count, type: 'long', value: ->(account) { account.followers_count }
    field :created_at, type: 'date'
    field :last_status_at, type: 'date', value: ->(account) { account.last_status_at || account.created_at }
    field :domain, type: 'keyword', value: ->(account) { account.domain }
    field :is, type: 'keyword', value: ->(account) { account.searchable_is }
    field :emojis, type: 'keyword', value: ->(account) { account.searchable_emojis }
    field :tags, type: 'keyword', normalizer: 'tag', value: ->(account) { account.searchable_tags }
  end
end
