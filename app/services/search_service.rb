# frozen_string_literal: true

class SearchService < BaseService
  def call(query, limit, resolve = false)
    return if query.blank? || query.start_with?('#')

    username, domain = query.gsub(/\A@/, '').split('@')

    if domain.nil?
      exact_match = Account.find_local(username)
      results     = Account.search_for(username)
    else
      exact_match = Account.find_remote(username, domain)
      results     = Account.search_for("#{username} #{domain}")
    end

    results = results.limit(limit).to_a
    results = [exact_match] + results.reject { |a| a.id == exact_match.id } if exact_match

    if resolve && results.empty? && !domain.nil?
      results = [FollowRemoteAccountService.new.call("#{username}@#{domain}")]
    end

    results
  end
end
