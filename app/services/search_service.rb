# frozen_string_literal: true
#
# Mastodon, a GNU Social-compatible microblogging server
# Copyright (C) 2016-2017 Eugen Rochko & al (see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

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
