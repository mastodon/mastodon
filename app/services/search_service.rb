# frozen_string_literal: true

class SearchService < BaseService
  def call(query, limit, resolve = false)
    return if query.blank?

    username, domain = query.split('@')

    results = if domain.nil?
                Account.search_for(username)
              else
                Account.search_for("#{username} #{domain}")
              end

    results = results.limit(limit)

    if resolve && results.empty? && !domain.nil?
      results = [FollowRemoteAccountService.new.call("#{username}@#{domain}")]
    end

    results
  end
end
