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

    username, domain = split_query_string
    domain = nil if TagManager.instance.local_domain?(domain)

    if domain.nil?
      exact_match = Account.find_local(username)
      results     = account.nil? ? Account.search_for(username, limit) : Account.advanced_search_for(username, account, limit)
    else
      exact_match = Account.find_remote(username, domain)
      results     = account.nil? ? Account.search_for("#{username} #{domain}", limit) : Account.advanced_search_for("#{username} #{domain}", account, limit)
    end

    results = [exact_match] + results.reject { |a| a.id == exact_match.id } if exact_match

    if resolve && !exact_match && !domain.nil?
      results = [FollowRemoteAccountService.new.call("#{username}@#{domain}")]
    end

    results
  end

  def query_blank_or_hashtag?
    query.blank? || query.start_with?('#')
  end

  def split_query_string
    query.gsub(/\A@/, '').split('@')
  end
end
