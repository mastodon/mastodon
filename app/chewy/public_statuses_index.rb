# frozen_string_literal: true

class PublicStatusesIndex < Chewy::Index
  settings index: index_preset(refresh_interval: '30s', number_of_shards: 5), analysis: {
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
  }

  index_scope ::Status.unscoped
                      .kept
                      .without_reblogs
                      .includes(:media_attachments, :preloadable_poll, :preview_cards)
                      .joins(:account)
                      .where(accounts: { discoverable: true })
                      .where(visibility: :public)

  root date_detection: false do
    field(:id, type: 'keyword')
    field(:account_id, type: 'long')
    field(:text, type: 'text', analyzer: 'whitespace', value: ->(status) { status.searchable_text }) { field(:stemmed, type: 'text', analyzer: 'content') }
    field(:language, type: 'keyword')
    field(:properties, type: 'keyword', value: ->(status) { status.searchable_properties })
    field(:created_at, type: 'date')
  end
end
