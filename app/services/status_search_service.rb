# frozen_string_literal: true

class StatusSearchService < BaseService
  def call(query, account = nil, options = {})
    @query   = query&.strip
    @account = account
    @options = options
    @limit   = options[:limit].to_i
    @offset  = options[:offset].to_i

    status_search_results
  end

  private

  def status_search_results
    definition = search_definition

    definition = definition.filter(term: { account_id: @options[:account_id] }) if @options[:account_id].present?

    if @options[:min_id].present? || @options[:max_id].present?
      range      = {}
      range[:gt] = @options[:min_id].to_i if @options[:min_id].present?
      range[:lt] = @options[:max_id].to_i if @options[:max_id].present?
      definition = definition.filter(range: { id: range })
    end

    results             = definition.limit(@limit).offset(@offset).objects.compact
    account_ids         = results.map(&:account_id)
    account_domains     = results.map(&:account_domain)
    preloaded_relations = @account.relations_map(account_ids, account_domains)

    results.reject { |status| StatusFilter.new(status, @account, preloaded_relations).filtered? }
  rescue Faraday::ConnectionFailed, Parslet::ParseFailed
    []
  end

  def search_definition
    non_publicly_searchable_clauses = non_publicly_searchable
    publicly_searchable_clauses = publicly_searchable

    filter = {
      bool: {
        should: [
          non_publicly_searchable_clauses,
          publicly_searchable_clauses,
        ],
        minimum_should_match: 1,
      },
    }

    StatusesIndex.query(filter)
  end

  def publicly_searchable
    parsed_query.apply(
      {
        bool: {
          must: [
            { term: { publicly_searchable: true } },
          ],
        },
      }
    )
  end

  def non_publicly_searchable
    parsed_query.apply(
      {
        bool: {
          must: [
            { term: { publicly_searchable: false } },
          ],
          filter: [
            { term: { searchable_by: @account.id } },
          ],
        },
      }
    )
  end

  def parsed_query
    SearchQueryTransformer.new.apply(SearchQueryParser.new.parse(@query))
  end
end
