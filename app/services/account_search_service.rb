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
    return [] if query_blank_or_hashtag? || limit < 1

    if resolving_non_matching_remote_account?
      [FollowRemoteAccountService.new.call("#{query_username}@#{query_domain}")]
    else
      search_results_and_exact_match.compact.uniq.slice(0, limit)
    end
  end

  def resolving_non_matching_remote_account?
    resolve && !exact_match && !domain_is_local?
  end

  def search_results_and_exact_match
    exact = [exact_match]
    return exact if !exact[0].nil? && limit == 1
    exact + search_results.to_a
  end

  def query_blank_or_hashtag?
    query.blank? || query.start_with?('#')
  end

  def split_query_string
    @_split_query_string ||= query.gsub(/\A@/, '').split('@')
  end

  def query_username
    @_query_username ||= split_query_string.first || ''
  end

  def query_domain
    @_query_domain ||= query_without_split? ? nil : split_query_string.last
  end

  def query_without_split?
    split_query_string.size == 1
  end

  def domain_is_local?
    @_domain_is_local ||= TagManager.instance.local_domain?(query_domain)
  end

  def exact_match
    @_exact_match ||= Account.find_remote(query_username, query_domain)
  end

  def search_results
    @_search_results ||= begin
      if account
        advanced_search_results
      else
        simple_search_results
      end
    end
  end

  def advanced_search_results
    Account.advanced_search_for(terms_for_query, account, limit)
  end

  def simple_search_results
    Account.search_for(terms_for_query, limit)
  end

  def terms_for_query
    if domain_is_local?
      query_username
    else
      "#{query_username} #{query_domain}"
    end
  end
end
