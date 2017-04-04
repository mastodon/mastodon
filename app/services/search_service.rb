# frozen_string_literal: true

class SearchService < BaseService
  def call(query, limit, resolve = false, account = nil)
    results = { accounts: [], hashtags: [], statuses: [] }

    return results if query.blank?

    if query =~ /\Ahttps?:\/\//
      resource = FetchRemoteResourceService.new.call(query)

      results[:accounts] << resource if resource.is_a?(Account)
      results[:statuses] << resource if resource.is_a?(Status)
    else
      results[:accounts] = AccountSearchService.new.call(query, limit, resolve, account)
      results[:hashtags] = Tag.search_for(query.gsub(/\A#/, ''), limit) unless query.start_with?('@')
    end

    results
  end
end
