# frozen_string_literal: true

class PublicStatusesIndex < Chewy::Index
  include FormattingHelper

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

  # We do not use delete_if option here because it would call a method that we
  # expect to be called with crutches without crutches, causing n+1 queries
  index_scope ::Status.unscoped
                      .kept
                      .without_reblogs
                      .includes(:media_attachments, :preloadable_poll)
                      .joins(:account)
                      .where(accounts: { discoverable: true })
                      .where(visibility: :public)

  root date_detection: false do
    field(:id, type: 'long')
    field(:account_id, type: 'long')

    field(:text, type: 'text', value: ->(status) { status.searchable_text }) do
      field(:stemmed, type: 'text', analyzer: 'content')
    end
  end
end
