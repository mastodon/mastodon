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
      natural: {
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

      verbatim: {
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

  index_scope ::Account.searchable.includes(:account_stat)

  root date_detection: false do
    field(:id, type: 'long')
    field(:following_count, type: 'long')
    field(:followers_count, type: 'long')
    field(:properties, type: 'keyword', value: ->(account) { account.searchable_properties })
    field(:last_status_at, type: 'date', value: ->(account) { account.last_status_at || account.created_at })
    field(:display_name, type: 'text', analyzer: 'verbatim') { field :edge_ngram, type: 'text', analyzer: 'edge_ngram', search_analyzer: 'verbatim' }
    field(:username, type: 'text', analyzer: 'verbatim', value: ->(account) { [account.username, account.domain].compact.join('@') }) { field :edge_ngram, type: 'text', analyzer: 'edge_ngram', search_analyzer: 'verbatim' }
    field(:text, type: 'text', value: ->(account) { account.searchable_text }) { field :stemmed, type: 'text', analyzer: 'natural' }
  end
end
