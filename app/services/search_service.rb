# frozen_string_literal: true

class SearchService < BaseService
  QUOTE_EQUIVALENT_CHARACTERS = /[“”„«»「」『』《》]/

  def call(query, account, limit, options = {})
    @query     = query&.strip&.gsub(QUOTE_EQUIVALENT_CHARACTERS, '"')
    @account   = account
    @options   = options
    @limit     = limit.to_i
    @offset    = options[:type].blank? ? 0 : options[:offset].to_i
    @resolve   = options[:resolve] || false
    @following = options[:following] || false

    default_results.tap do |results|
      next if @query.blank? || @limit.zero?

      if url_query?
        results.merge!(url_resource_results) unless url_resource.nil? || @offset.positive? || (@options[:type].present? && url_resource_symbol != @options[:type].to_sym)
      elsif @query.present?
        results[:accounts] = perform_accounts_search! if account_searchable?
        results[:statuses] = perform_statuses_search! if status_searchable?
        results[:hashtags] = perform_hashtags_search! if hashtag_searchable?
      end
    end
  end

  private

  def perform_accounts_search!
    AccountSearchService.new.call(
      @query,
      @account,
      limit: @limit,
      resolve: @resolve,
      offset: @offset,
      use_searchable_text: true,
      following: @following,
      start_with_hashtag: @query.start_with?('#')
    )
  end

  def perform_statuses_search!
    StatusesSearchService.new.call(
      @query,
      @account,
      limit: @limit,
      offset: @offset,
      account_id: @options[:account_id],
      min_id: @options[:min_id],
      max_id: @options[:max_id]
    )
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
    @resolve && %r{\Ahttps?://}.match?(@query)
  end

  def url_resource_results
    { url_resource_symbol => [url_resource] }
  end

  def url_resource
    @url_resource ||= ResolveURLService.new.call(@query, on_behalf_of: @account)
  end

  def url_resource_symbol
    url_resource.class.name.downcase.pluralize.to_sym
  end

  def status_searchable?
    Chewy.enabled? && status_search? && @account.present?
  end

  def account_searchable?
    account_search?
  end

  def hashtag_searchable?
    hashtag_search?
  end

  def account_search?
    @options[:type].blank? || @options[:type] == 'accounts'
  end

  def hashtag_search?
    @options[:type].blank? || @options[:type] == 'hashtags'
  end

  def status_search?
    @options[:type].blank? || @options[:type] == 'statuses'
  end
end
