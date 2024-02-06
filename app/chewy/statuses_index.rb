# frozen_string_literal: true

class StatusesIndex < Chewy::Index
  include DatetimeClampingConcern

  settings index: index_preset(refresh_interval: '30s', number_of_shards: 5), analysis: {
    tokenizer: {
      sudachi_tokenizer: {
        type: 'sudachi_tokenizer',
        discard_punctuation: true,
        resources_path: '/usr/share/elasticsearch/config/sudachi',
        settings_path: '/usr/share/elasticsearch/config/sudachi/sudachi.json',
      },
    },
    filter: {
      english_stop: {
        type: 'stop',
        stopwords: '_english_',
      },
      sudachi_split_filter: {
        type: 'sudachi_split',
        mode: 'search',
      },
      english_stemmer: {
        type: 'stemmer',
        language: 'english',
      },

      english_possessive_stemmer: {
        type: 'stemmer',
        language: 'possessive_english',
      },
      sudachi_split_filter: {
        type: "sudachi_split",
        mode: "search"
      },
    },

    analyzer: {
      verbatim: {
        tokenizer: 'uax_url_email',
        filter: %w(lowercase),
      },

      content: {
        tokenizer: 'sudachi_tokenizer',
        type: 'custom',
        filter: %w(
          lowercase
          cjk_width
          sudachi_split_filter
          sudachi_part_of_speech
          sudachi_ja_stop
          sudachi_baseform
          english_possessive_stemmer
          elision
          english_stop
          english_stemmer
        ),
      },

      hashtag: {
        tokenizer: 'keyword',
        filter: %w(
          word_delimiter_graph
          lowercase
          asciifolding
          cjk_width
        ),
      },
    },
  }

  index_scope ::Status.unscoped.kept.without_reblogs.includes(:media_attachments, :preview_cards, :local_mentioned, :local_favorited, :local_reblogged, :local_bookmarked, :tags, preloadable_poll: :local_voters), delete_if: ->(status) { status.searchable_by.empty? }

  root date_detection: false do
    field(:id, type: 'long')
    field(:account_id, type: 'long')
    field(:text, type: 'text', analyzer: 'verbatim', value: ->(status) { status.searchable_text }) { field(:stemmed, type: 'text', analyzer: 'content') }
    field(:tags, type: 'text', analyzer: 'hashtag',  value: ->(status) { status.tags.map(&:display_name) })
    field(:searchable_by, type: 'long', value: ->(status) { status.searchable_by })
    field(:searchable_by_anyone, type: 'boolean', value: ->(status) { status.public_visibility? })
    field(:language, type: 'keyword')
    field(:properties, type: 'keyword', value: ->(status) { status.searchable_properties })
    field(:created_at, type: 'date', value: ->(status) { clamp_date(status.created_at) })
  end
end
