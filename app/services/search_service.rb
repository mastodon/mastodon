# frozen_string_literal: true

class SearchService < BaseService
  def call(query, limit, resolve = false, account = nil)
    return if query.blank?

    results = { accounts: [], hashtags: [], statuses: [] }

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
