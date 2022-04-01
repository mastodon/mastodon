# frozen_string_literal: true

class TagsIndex < Chewy::Index
  settings index: { refresh_interval: '15m' }, analysis: {
    analyzer: {
      content: {
        tokenizer: 'keyword',
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
        min_gram: 2,
        max_gram: 15,
      },
    },
  }

  index_scope ::Tag.listable, delete_if: ->(tag) { tag.destroyed? || !tag.listable? }

  root date_detection: false do
    field :name, type: 'text', analyzer: 'content' do
      field :edge_ngram, type: 'text', analyzer: 'edge_ngram', search_analyzer: 'content'
    end

    field :reviewed, type: 'boolean', value: ->(tag) { tag.reviewed? }
    field :usage, type: 'long', value: ->(tag) { tag.history.reduce(0) { |total, day| total + day.accounts } }
    field :last_status_at, type: 'date', value: ->(tag) { tag.last_status_at || tag.created_at }
  end
end
