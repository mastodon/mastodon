# frozen_string_literal: true

class SearchService < BaseService
  def call(query, limit, resolve = false, account = nil)
    return if query.blank? || query.start_with?('#')

    username, domain = query.gsub(/\A@/, '').split('@')
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
end
