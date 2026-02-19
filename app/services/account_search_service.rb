# frozen_string_literal: true

class AccountSearchService < BaseService
  attr_reader :query, :limit, :offset, :options, :account

  MENTION_ONLY_RE = /\A#{Account::MENTION_RE}\z/i

  # Min. number of characters to look for non-exact matches
  MIN_QUERY_LENGTH = 3

  class QueryBuilder
    def initialize(query, account, options = {})
      @query = query
      @account = account
      @options = options
    end

    def build
      AccountsIndex.query(
        bool: {
          must: {
            function_score: {
              query: {
                bool: {
                  must: must_clauses,
                  must_not: must_not_clauses,
                },
              },

              functions: [
                followers_score_function,
              ],
            },
          },

          should: should_clauses,
        }
      )
    end

    private

    def must_clauses
      if @account && @options[:following]
        [core_query, only_following_query]
      else
        [core_query]
      end
    end

    def must_not_clauses
      []
    end

    def should_clauses
      if @account && !@options[:following]
        [boost_following_query]
      else
        []
      end
    end

    # This function limits results to only the accounts the user is following
    def only_following_query
      {
        terms: {
          id: following_ids,
        },
      }
    end

    # This function promotes accounts the user is following
    def boost_following_query
      {
        terms: {
          id: following_ids,
          boost: 100,
        },
      }
    end

    # This function promotes accounts that have more followers
    def followers_score_function
      {
        script_score: {
          script: {
            source: "Math.log10((Math.max(doc['followers_count'].value, 0) + 1))",
          },
        },
      }
    end

    def following_ids
      @following_ids ||= @account.active_relationships.pluck(:target_account_id) + [@account.id]
    end
  end

  class AutocompleteQueryBuilder < QueryBuilder
    private

    def core_query
      {
        dis_max: {
          queries: [
            {
              multi_match: {
                query: @query,
                type: 'most_fields',
                fields: %w(username username.*),
              },
            },

            {
              multi_match: {
                query: @query,
                type: 'most_fields',
                fields: %w(display_name display_name.*),
              },
            },
          ],
        },
      }
    end
  end

  class FullQueryBuilder < QueryBuilder
    private

    def core_query
      {
        dis_max: {
          queries: [
            {
              match: {
                username: {
                  query: @query,
                  analyzer: 'word_join_analyzer',
                },
              },
            },

            {
              match: {
                display_name: {
                  query: @query,
                  analyzer: 'word_join_analyzer',
                },
              },
            },

            {
              multi_match: {
                query: @query,
                type: 'best_fields',
                fields: %w(text text.*),
                operator: 'and',
              },
            },
          ],

          tie_breaker: 0.5,
        },
      }
    end
  end

  def call(query, account = nil, options = {})
    MastodonOTELTracer.in_span('AccountSearchService#call') do |span|
      @query   = query&.strip&.gsub(/\A@/, '')
      @limit   = options[:limit].to_i
      @offset  = options[:offset].to_i
      @options = options
      @account = account

      span.add_attributes(
        'search.offset' => @offset,
        'search.limit' => @limit,
        'search.backend' => Chewy.enabled? ? 'elasticsearch' : 'database'
      )

      # Trigger searching accounts using providers.
      # This will not return any immediate results but has the
      # potential to fill the local database with relevant
      # accounts for the next time the search is performed.
      Fasp::AccountSearchWorker.perform_async(@query) if options[:query_fasp]

      search_service_results.compact.uniq.tap do |results|
        span.set_attribute('search.results.count', results.size)
      end
    end
  end

  private

  def search_service_results
    return [] if query.blank? || limit < 1

    [exact_match] + search_results
  end

  def exact_match
    return unless offset.zero? && username_complete?

    return @exact_match if defined?(@exact_match)

    match = if options[:resolve]
              ResolveAccountService.new.call(query)
            elsif domain_is_local?
              Account.find_local(query_username)
            else
              Account.find_remote(query_username, query_domain)
            end

    match = nil if !match.nil? && !account.nil? && options[:following] && !account.following?(match)

    @exact_match = match
  end

  def search_results
    return [] if limit_for_non_exact_results.zero?

    @search_results ||= begin
      results = from_elasticsearch if Chewy.enabled?
      results ||= from_database
      results
    end
  end

  def from_database
    if account
      advanced_search_results
    else
      simple_search_results
    end
  end

  def advanced_search_results
    Account.advanced_search_for(terms_for_query, account, limit: limit_for_non_exact_results, following: options[:following], offset: offset)
  end

  def simple_search_results
    Account.search_for(terms_for_query, limit: limit_for_non_exact_results, offset: offset)
  end

  def from_elasticsearch
    query_builder = begin
      if options[:use_searchable_text]
        FullQueryBuilder.new(terms_for_query, account, options.slice(:following))
      else
        AutocompleteQueryBuilder.new(terms_for_query, account, options.slice(:following))
      end
    end

    records = query_builder.build.limit(limit_for_non_exact_results).offset(offset).objects.compact

    ActiveRecord::Associations::Preloader.new(records: records, associations: [:account_stat, { user: :role }]).call

    records
  rescue Faraday::ConnectionFailed, Parslet::ParseFailed, Errno::ENETUNREACH
    nil
  end

  def limit_for_non_exact_results
    return 0 if @account.nil? && query.size < MIN_QUERY_LENGTH

    if exact_match?
      limit - 1
    else
      limit
    end
  end

  def terms_for_query
    if domain_is_local?
      query_username
    else
      query
    end
  end

  def split_query_string
    @split_query_string ||= query.split('@')
  end

  def query_username
    @query_username ||= split_query_string.first || ''
  end

  def query_domain
    @query_domain ||= query_without_split? ? nil : split_query_string.last
  end

  def query_without_split?
    split_query_string.size == 1
  end

  def domain_is_local?
    @domain_is_local ||= TagManager.instance.local_domain?(query_domain)
  end

  def exact_match?
    exact_match.present?
  end

  def username_complete?
    query.include?('@') && "@#{query}".match?(MENTION_ONLY_RE)
  end
end
