# frozen_string_literal: true

class AccountSearchService < BaseService
  attr_reader :query, :limit, :resolve, :account

  def call(query, limit, resolve = false, account = nil)
    @query = query
    @limit = limit
    @resolve = resolve
    @account = account

    search_service_results
  end

  private

  def search_service_results
    return [] if query_blank_or_hashtag?

    if domain_is_local?
      exact_match = Account.find_local(query_username)
      results     = account.nil? ? Account.search_for(query_username, limit) : Account.advanced_search_for(query_username, account, limit)
    else
      exact_match = Account.find_remote(query_username, query_domain)
      results     = account.nil? ? Account.search_for("#{query_username} #{query_domain}", limit) : Account.advanced_search_for("#{query_username} #{query_domain}", account, limit)
    end

    results = [exact_match] + results.reject { |a| a.id == exact_match.id } if exact_match

    if resolve && !exact_match && !domain_is_local?
      results = [FollowRemoteAccountService.new.call("#{query_username}@#{query_domain}")]
    end

    results
  end

  def query_blank_or_hashtag?
    query.blank? || query.start_with?('#')
  end

  def split_query_string
    query.gsub(/\A@/, '').split('@')
  end

  def query_username
    split_query_string.first
  end

  def query_domain
    query_without_split? ? nil : split_query_string.last
  end

  def query_without_split?
    split_query_string.size == 1
  end

  def domain_is_local?
    TagManager.instance.local_domain?(query_domain)
  end
end
