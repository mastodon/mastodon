# frozen_string_literal: true

class SearchService < BaseService
  attr_accessor :query

  def call(query, limit, resolve = false, account = nil)
    @query = query

    default_results.tap do |results|
      if url_query?
        results.merge!(remote_resource_results) unless remote_resource.nil?
      elsif query.present?
        results[:accounts] = AccountSearchService.new.call(query, limit, resolve, account)
        results[:hashtags] = Tag.search_for(query.gsub(/\A#/, ''), limit) unless query.start_with?('@')
      end
    end
  end

  def default_results
    { accounts: [], hashtags: [], statuses: [] }
  end

  def url_query?
    query =~ /\Ahttps?:\/\//
  end

  def remote_resource_results
    { remote_resource_symbol => [remote_resource] }
  end

  def remote_resource
    @_remote_resource ||= FetchRemoteResourceService.new.call(query)
  end

  def remote_resource_symbol
    remote_resource.class.name.downcase.pluralize.to_sym
  end
end
