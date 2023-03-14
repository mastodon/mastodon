# frozen_string_literal: true

class SearchService < BaseService
  def call(query, account, limit, options = {})
    @query   = query&.strip
    @account = account
    @options = options
    @limit   = limit.to_i
    @offset  = options[:type].blank? ? 0 : options[:offset].to_i
    @resolve = options[:resolve] || false

    default_results.tap do |results|
      next if @query.blank? || @limit.zero?

      results.merge!(url_resource_results) { |_, a, b| a | b } if
        url_query? && !(
          url_resource.nil? ||
            @offset.positive? ||
            (
              @options[:type].present? &&
                url_resource_symbol != @options[:type].to_sym
            )
        )

      results.merge!(search_results) { |_, a, b| a | b } if @query.present?
    end
  end

  private

  def merge_list_values(_key, list1, list2)
    list1 | list2
  end

  # Perform searches that aren't a request to resolve an URL
  # (including searching for an URL as a search term).
  #
  # Account and status searches use different sets of prefix operators,
  # and hashtag searches don't use the advanced search syntax at all.
  # Throw a syntax error only if the syntax is invalid in all search contexts.
  def search_results
    results = {}
    search_succeeded = false
    syntax_error = nil

    if account_searchable?
      begin
        results[:accounts] = perform_accounts_search!
        search_succeeded = true
      rescue Mastodon::SyntaxError => e
        syntax_error = e
      end
    end

    if status_searchable?
      begin
        results[:statuses] = perform_statuses_search!
        search_succeeded = true
      rescue Mastodon::SyntaxError => e
        syntax_error = e
      end
    end

    if hashtag_searchable?
      begin
        results[:hashtags] = perform_hashtags_search!
        search_succeeded = true
      rescue Mastodon::SyntaxError => e
        syntax_error = e
      end
    end

    raise syntax_error unless syntax_error.nil? || search_succeeded

    results
  end

  def perform_accounts_search!
    AccountSearchService.new.call(
      @query,
      @account,
      limit: @limit,
      resolve: @resolve,
      offset: @offset
    )
  end

  def perform_statuses_search!
    required_account_ids = parsed_query.statuses_required_account_ids
    return [] if @account.blocked_by.exists?(id: required_account_ids)

    definition = StatusesIndex.filter(term: { searchable_by: @account.id })
    definition = parsed_query.statuses_apply(definition, following_ids)
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
    preloaded_relations = relations_map_for_account(@account, account_ids, account_domains)

    results.reject { |status| StatusFilter.new(status, @account, preloaded_relations).filtered? }
  rescue Faraday::ConnectionFailed, Parslet::ParseFailed
    []
  end

  def perform_hashtags_search!
    TagSearchService.new.call(
      @query,
      limit: @limit,
      offset: @offset,
      exclude_unreviewed: @options[:exclude_unreviewed]
    )
  end

  def default_results
    { accounts: [], hashtags: [], statuses: [] }
  end

  def url_query?
    @resolve && /\Ahttps?:\/\//.match?(@query)
  end

  def url_resource_results
    { url_resource_symbol => [url_resource] }
  end

  def url_resource
    @_url_resource ||= ResolveURLService.new.call(@query, on_behalf_of: @account)
  end

  def url_resource_symbol
    url_resource.class.name.downcase.pluralize.to_sym
  end

  def status_searchable?
    return false unless Chewy.enabled?

    statuses_search? && !@account.nil?
  end

  def account_searchable?
    account_search?
  end

  def hashtag_searchable?
    hashtag_search? && !@query.include?('@')
  end

  def account_search?
    @options[:type].blank? || @options[:type] == 'accounts'
  end

  def hashtag_search?
    @options[:type].blank? || @options[:type] == 'hashtags'
  end

  def statuses_search?
    @options[:type].blank? || @options[:type] == 'statuses'
  end

  def relations_map_for_account(account, account_ids, domains)
    {
      blocking: Account.blocking_map(account_ids, account.id),
      blocked_by: Account.blocked_by_map(account_ids, account.id),
      muting: Account.muting_map(account_ids, account.id),
      following: Account.following_map(account_ids, account.id),
      domain_blocking_by_domain: Account.domain_blocking_map_by_domain(domains, account.id),
    }
  end

  def parsed_query
    SearchQueryTransformer.new.apply(SearchQueryParser.new.parse(@query))
  end

  def following_ids
    @following_ids ||= @account.active_relationships.pluck(:target_account_id) + [@account.id]
  end
end
