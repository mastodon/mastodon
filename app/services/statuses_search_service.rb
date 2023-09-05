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
    request             = parsed_query.request
    results             = request.collapse(field: :id).order(id: { order: :desc }).limit(@limit).offset(@offset).objects.compact
    account_ids         = results.map(&:account_id)
    account_domains     = results.map(&:account_domain)
    preloaded_relations = @account.relations_map(account_ids, account_domains)

    results.reject { |status| StatusFilter.new(status, @account, preloaded_relations).filtered? }
  rescue Faraday::ConnectionFailed, Parslet::ParseFailed
    []
  end

  def parsed_query
    SearchQueryTransformer.new.apply(SearchQueryParser.new.parse(@query), current_account: @account)
  end
end
