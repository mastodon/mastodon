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

class FetchAtomService < BaseService
  include HttpHelper

  def call(url)
    return if url.blank?

    response = http_client.head(url)

    Rails.logger.debug "Remote status HEAD request returned code #{response.code}"

    response = http_client.get(url) if response.code == 405

    Rails.logger.debug "Remote status GET request returned code #{response.code}"

    return nil if response.code != 200
    return [url, fetch(url)] if response.mime_type == 'application/atom+xml'
    return process_headers(url, response) unless response['Link'].blank?
    process_html(fetch(url))
  rescue OpenSSL::SSL::SSLError => e
    Rails.logger.debug "SSL error: #{e}"
  end

  private

  def process_html(body)
    Rails.logger.debug 'Processing HTML'

    page = Nokogiri::HTML(body)
    alternate_link = page.xpath('//link[@rel="alternate"]').find { |link| link['type'] == 'application/atom+xml' }

    return nil if alternate_link.nil?
    [alternate_link['href'], fetch(alternate_link['href'])]
  end

  def process_headers(url, response)
    Rails.logger.debug 'Processing link header'

    link_header    = LinkHeader.parse(response['Link'].is_a?(Array) ? response['Link'].first : response['Link'])
    alternate_link = link_header.find_link(%w(rel alternate), %w(type application/atom+xml))

    return process_html(fetch(url)) if alternate_link.nil?
    [alternate_link.href, fetch(alternate_link.href)]
  end

  def fetch(url)
    http_client.get(url).to_s
  end
end
