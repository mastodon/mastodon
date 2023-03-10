# frozen_string_literal: true

class StatusesIndex < Chewy::Index
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

  # We do not use delete_if option here because it would call a method that we
  # expect to be called with crutches without crutches, causing n+1 queries
  index_scope ::Status.unscoped.kept.without_reblogs.includes(:media_attachments, :preloadable_poll)

  crutch :mentions do |collection|
    data = ::Mention.where(status_id: collection.map(&:id)).where(account: Account.local, silent: false).pluck(:status_id, :account_id)
    data.each.with_object({}) { |(id, name), result| (result[id] ||= []).push(name) }
  end

  crutch :favourites do |collection|
    data = ::Favourite.where(status_id: collection.map(&:id)).where(account: Account.local).pluck(:status_id, :account_id)
    data.each.with_object({}) { |(id, name), result| (result[id] ||= []).push(name) }
  end

  crutch :reblogs do |collection|
    data = ::Status.where(reblog_of_id: collection.map(&:id)).where(account: Account.local).pluck(:reblog_of_id, :account_id)
    data.each.with_object({}) { |(id, name), result| (result[id] ||= []).push(name) }
  end

  crutch :bookmarks do |collection|
    data = ::Bookmark.where(status_id: collection.map(&:id)).where(account: Account.local).pluck(:status_id, :account_id)
    data.each.with_object({}) { |(id, name), result| (result[id] ||= []).push(name) }
  end

  crutch :votes do |collection|
    data = ::PollVote.joins(:poll).where(poll: { status_id: collection.map(&:id) }).where(account: Account.local).pluck(:status_id, :account_id)
    data.each.with_object({}) { |(id, name), result| (result[id] ||= []).push(name) }
  end

  root date_detection: false do
    field :id, type: 'long'
    field :account_id, type: 'long'
    field :created_at, type: 'date'
    field :domain, type: 'keyword', value: ->(status) { status.account.domain }
    field :lang, type: 'keyword', value: ->(status) { status.language }
    field :is, type: 'keyword', value: ->(status) { status.searchable_is }
    field :has, type: 'keyword', value: ->(status) { status.searchable_has }
    field :emojis, type: 'keyword', value: ->(status) { status.searchable_emojis }
    field :tags, type: 'keyword', normalizer: 'tag', value: ->(status) { status.searchable_tags }
    field :mentions_ids, type: 'long', value: ->(status) { status.searchable_mentions_ids }

    field :text, type: 'text', value: ->(status) { status.searchable_text } do
      field :stemmed, type: 'text', analyzer: 'content'
    end

    field :searchable_by, type: 'long', value: ->(status, crutches) { status.searchable_by(crutches) }
  end
end
