# frozen_string_literal: true

class TagSearchService < BaseService
  def call(query, options = {})
    @query  = query.strip.gsub(/\A#/, '')
    @offset = options[:offset].to_i
    @limit  = options[:limit].to_i

    results = from_elasticsearch if Chewy.enabled?
    results ||= from_database

    results
  end

  private

  def from_elasticsearch
    query = {
      function_score: {
        query: {
          multi_match: {
            query: @query,
            fields: %w(name.edge_ngram name),
            type: 'most_fields',
            operator: 'and',
          },
        },

        functions: [
          {
            field_value_factor: {
              field: 'usage',
              modifier: 'log2p',
              missing: 0,
            },
          },

          {
            gauss: {
              last_status_at: {
                scale: '7d',
                offset: '14d',
                decay: 0.5,
              },
            },
          },
        ],

        boost_mode: 'multiply',
      },
    }

    filter = {
      bool: {
        should: [
          {
            term: {
              reviewed: {
                value: true,
              },
            },
          },

          {
            term: {
              name: {
                value: @query,
              },
            },
          },
        ],
      },
    }

    TagsIndex.query(query).filter(filter).limit(@limit).offset(@offset).objects.compact
  rescue Faraday::ConnectionFailed, Parslet::ParseFailed
    nil
  end

  def from_database
    Tag.search_for(@query, @limit, @offset)
  end
end
