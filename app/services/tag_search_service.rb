# frozen_string_literal: true

class TagSearchService < BaseService
  def call(query, options = {})
    @query   = query.strip.delete_prefix('#')
    @offset  = options.delete(:offset).to_i
    @limit   = options.delete(:limit).to_i
    @options = options

    results   = from_elasticsearch if Chewy.enabled?
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
            match: {
              name: {
                query: @query,
              },
            },
          },
        ],
      },
    }

    definition = TagsIndex.query(query)
    definition = definition.filter(filter) if @options[:exclude_unreviewed]

    ensure_exact_match(definition.limit(@limit).offset(@offset).objects.compact)
  rescue Faraday::ConnectionFailed, Parslet::ParseFailed
    nil
  end

  # Since the ElasticSearch Query doesn't guarantee the exact match will be the
  # first result or that it will even be returned, patch the results accordingly
  def ensure_exact_match(results)
    return results unless @offset.nil? || @offset.zero?

    normalized_query = Tag.normalize(@query)
    exact_match = results.find { |tag| tag.name.downcase == normalized_query }
    exact_match ||= Tag.find_normalized(normalized_query)
    unless exact_match.nil?
      results.delete(exact_match)
      results = [exact_match] + results
    end

    results
  end

  def from_database
    Tag.search_for(@query, @limit, @offset, @options)
  end
end
