# frozen_string_literal: true

class StatusesSearchService < BaseService
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
    definition = parsed_query.apply(
      StatusesIndex.filter(
        bool: {
          should: [
            publicly_searchable,
            non_publicly_searchable,
          ],
          minimum_should_match: 1,
        }
      )
    )

    definition = definition.filter(term: { account_id: @options[:account_id] }) if @options[:account_id].present?

    if @options[:min_id].present? || @options[:max_id].present?
      range      = {}
      range[:gt] = @options[:min_id].to_i if @options[:min_id].present?
      range[:lt] = @options[:max_id].to_i if @options[:max_id].present?
      definition = definition.filter(range: { id: range })
    end

    # This is the best way to submit identical queries to multi-indexes though chewy
    definition.instance_variable_get(:@parameters)[:indices].value[:indices] << PublicStatusesIndex

    results             = definition.limit(@limit).offset(@offset).objects.compact
    account_ids         = results.map(&:account_id)
    account_domains     = results.map(&:account_domain)
    preloaded_relations = @account.relations_map(account_ids, account_domains)

    results.reject { |status| StatusFilter.new(status, @account, preloaded_relations).filtered? }
  rescue Faraday::ConnectionFailed, Parslet::ParseFailed
    []
  end

  def publicly_searchable
    {
      bool: {
        must_not: {
          exists: {
            field: 'searchable_by',
          },
        },
      },
    }
  end

  def non_publicly_searchable
    {
      bool: {
        must: [
          {
            exists: {
              field: 'searchable_by',
            },
          },
          {
            term: { searchable_by: @account.id },
          },
        ],
      },
    }
  end

  def parsed_query
    SearchQueryTransformer.new.apply(SearchQueryParser.new.parse(@query))
  end
end
