# frozen_string_literal: true

class AccountsIndex < Chewy::Index
  include DatetimeClampingConcern

  settings index: index_preset(refresh_interval: '30s'), analysis: {
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

      word_joiner: {
        type: 'shingle',
        output_unigrams: true,
        token_separator: '',
      },
    },

    analyzer: {
      # "The FOOING's bar" becomes "foo bar"
      natural: {
        tokenizer: 'standard',
        filter: %w(
          lowercase
          asciifolding
          cjk_width
          elision
          english_possessive_stemmer
          english_stop
          english_stemmer
        ),
      },

      # "FOO bar" becomes "foo bar"
      verbatim: {
        tokenizer: 'standard',
        filter: %w(lowercase asciifolding cjk_width),
      },

      # "Foo bar" becomes "foo bar foobar"
      word_join_analyzer: {
        type: 'custom',
        tokenizer: 'standard',
        filter: %w(lowercase asciifolding cjk_width word_joiner),
      },

      # "Foo bar" becomes "f fo foo b ba bar"
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
    field(:last_status_at, type: 'date', value: ->(account) { clamp_date(account.last_status_at || account.created_at) })
    field(:display_name, type: 'text', analyzer: 'verbatim') { field :edge_ngram, type: 'text', analyzer: 'edge_ngram', search_analyzer: 'verbatim' }
    field(:username, type: 'text', analyzer: 'verbatim', value: ->(account) { [account.username, account.domain].compact.join('@') }) { field :edge_ngram, type: 'text', analyzer: 'edge_ngram', search_analyzer: 'verbatim' }
    field(:text, type: 'text', analyzer: 'verbatim', value: ->(account) { account.searchable_text }) { field :stemmed, type: 'text', analyzer: 'natural' }
  end
end
