# frozen_string_literal: true

class StatusesIndex < Chewy::Index
  settings index: { refresh_interval: '15m' }, analysis: {
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
    tokenizer: {
      ja_tokenizer: {
        type: 'kuromoji_neologd_tokenizer',
        mode: 'search',
      },
      ngram_tokenizer: {
        type: 'ngram',
        min_gram: 2,
        max_gram: 3,
        token_chars: %w(
          letter
          digit
        ),
      },
    },
    analyzer: {
      content: {
        tokenizer: 'kuromoji_neologd_tokenizer',
        char_filter: %w(
          icu_normalizer
          kuromoji_neologd_iteration_mark
        ),
        filter: %w(
          kuromoji_neologd_baseform
          kuromoji_neologd_part_of_speech
          ja_stop
          kuromoji_number
          kuromoji_neologd_stemmer
          icu_normalizer
        ),
      },
      ngram_analyzer: {
        tokenizer: 'ngram_tokenizer',
        char_filter: %w(
          icu_normalizer
        ),

      }
    },
  }

  define_type ::Status.unscoped.without_reblogs do
    crutch :mentions do |collection|
      data = ::Mention.where(status_id: collection.map(&:id)).pluck(:status_id, :account_id)
      data.each.with_object({}) { |(id, name), result| (result[id] ||= []).push(name) }
    end

    crutch :favourites do |collection|
      data = ::Favourite.where(status_id: collection.map(&:id)).pluck(:status_id, :account_id)
      data.each.with_object({}) { |(id, name), result| (result[id] ||= []).push(name) }
    end

    crutch :reblogs do |collection|
      data = ::Status.where(reblog_of_id: collection.map(&:id)).pluck(:reblog_of_id, :account_id)
      data.each.with_object({}) { |(id, name), result| (result[id] ||= []).push(name) }
    end

    root date_detection: false do
      field :account_id, type: 'long'

      field :text, type: 'text', value: ->(status) { [status.spoiler_text, Formatter.instance.plaintext(status)].join("\n\n") } do
        field :stemmed, type: 'text', analyzer: 'content'
      end

      field :searchable_by, type: 'long', value: ->(status, crutches) { status.searchable_by(crutches) }
      field :created_at, type: 'date'
    end
  end
end
