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

class FetchRemoteStatusService < BaseService
  include AuthorExtractor

  def call(url, prefetched_body = nil)
    if prefetched_body.nil?
      atom_url, body = FetchAtomService.new.call(url)
    else
      atom_url = url
      body     = prefetched_body
    end

    return nil if atom_url.nil?
    process_atom(atom_url, body)
  end

  private

  def process_atom(url, body)
    Rails.logger.debug "Processing Atom for remote status at #{url}"

    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    account = author_from_xml(xml.at_xpath('/xmlns:entry', xmlns: TagManager::XMLNS))
    domain  = Addressable::URI.parse(url).normalize.host

    return nil unless !account.nil? && confirmed_domain?(domain, account)

    statuses = ProcessFeedService.new.call(body, account)
    statuses.first
  rescue Nokogiri::XML::XPath::SyntaxError
    Rails.logger.debug 'Invalid XML or missing namespace'
    nil
  end

  def confirmed_domain?(domain, account)
    account.domain.nil? || domain.casecmp(account.domain).zero? || domain.casecmp(Addressable::URI.parse(account.remote_url).normalize.host).zero?
  end
end
