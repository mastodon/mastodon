# frozen_string_literal: true

class AccountSearchService < BaseService
  attr_reader :query, :limit, :offset, :options, :account

  MENTION_ONLY_RE = /\A#{Account::MENTION_RE}\z/i

  # Min. number of characters to look for non-exact matches
  MIN_QUERY_LENGTH = 5

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
                },
              },

              functions: [
                reputation_score_function,
                followers_score_function,
                time_distance_function,
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

    # This function deranks accounts that follow more people than follow them
    def reputation_score_function
      {
        script_score: {
          script: {
            source: "(Math.max(doc['followers_count'].value, 0) + 0.0) / (Math.max(doc['followers_count'].value, 0) + Math.max(doc['following_count'].value, 0) + 1)",
          },
        },
      }
    end

    # This function promotes accounts that have more followers
    def followers_score_function
      {
        script_score: {
          script: {
            source: "(Math.max(doc['followers_count'].value, 0) / (Math.max(doc['followers_count'].value, 0) + 1))",
          },
        },
      }
    end

    # This function deranks accounts that haven't posted in a long time
    def time_distance_function
      {
        gauss: {
          last_status_at: {
            scale: '30d',
            offset: '30d',
            decay: 0.3,
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
        multi_match: {
          query: @query,
          type: 'bool_prefix',
          fields: %w(username^2 username.*^2 display_name display_name.*),
        },
      }
    end
  end

  class FullQueryBuilder < QueryBuilder
    private

    def core_query
      {
        multi_match: {
          query: @query,
          type: 'most_fields',
          fields: %w(username^2 display_name^2 text text.*),
          operator: 'and',
        },
      }
    end
  end

  def call(query, account = nil, options = {})
    @query   = query&.strip&.gsub(/\A@/, '')
    @limit   = options[:limit].to_i
    @offset  = options[:offset].to_i
    @options = options
    @account = account

    search_service_results.compact.uniq
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

    ActiveRecord::Associations::Preloader.new(records: records, associations: :account_stat)

    records
  rescue Faraday::ConnectionFailed, Parslet::ParseFailed
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
