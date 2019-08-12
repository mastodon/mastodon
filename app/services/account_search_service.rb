# frozen_string_literal: true

class AccountSearchService < BaseService
  attr_reader :query, :limit, :offset, :options, :account

  def call(query, account = nil, options = {})
    @query   = query.strip
    @limit   = options[:limit].to_i
    @offset  = options[:offset].to_i
    @options = options
    @account = account

    search_service_results
  end

  private

  def search_service_results
    return [] if query_blank_or_hashtag? || limit < 1

    if resolving_non_matching_remote_account?
      [ResolveAccountService.new.call("#{query_username}@#{query_domain}")].compact
    else
      search_results_and_exact_match.compact.uniq
    end
  end

  def resolving_non_matching_remote_account?
    offset.zero? && options[:resolve] && !exact_match? && !domain_is_local?
  end

  def search_results_and_exact_match
    return search_results.to_a unless offset.zero?

    results = [exact_match]

    return results if exact_match? && limit == 1

    results + search_results.to_a
  end

  def query_blank_or_hashtag?
    query.blank? || query.start_with?('#')
  end

  def split_query_string
    @split_query_string ||= query.gsub(/\A@/, '').split('@')
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

  def search_from
    options[:following] && account ? account.following : Account
  end

  def exact_match?
    exact_match.present?
  end

  def exact_match
    return @exact_match if defined?(@exact_match)

    @exact_match = begin
      if domain_is_local?
        search_from.without_suspended.find_local(query_username)
      else
        search_from.without_suspended.find_remote(query_username, query_domain)
      end
    end
  end

  def search_results
    @search_results ||= begin
      if account
        advanced_search_results
      else
        simple_search_results
      end
    end
  end

  def advanced_search_results
    Account.advanced_search_for(terms_for_query, account, limit_for_non_exact_results, options[:following], offset)
  end

  def simple_search_results
    Account.search_for(terms_for_query, limit_for_non_exact_results, offset)
  end

  def limit_for_non_exact_results
    if offset.zero? && exact_match?
      limit - 1
    else
      limit
    end
  end

  def terms_for_query
    if domain_is_local?
      query_username
    else
      "#{query_username} #{query_domain}"
    end
  end
end
