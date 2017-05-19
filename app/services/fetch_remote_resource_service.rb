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

class FetchRemoteResourceService < BaseService
  attr_reader :url

  def call(url)
    @url = url
    process_url unless atom_url.nil?
  end

  private

  def process_url
    case xml_root
    when 'feed'
      FetchRemoteAccountService.new.call(atom_url, body)
    when 'entry'
      FetchRemoteStatusService.new.call(atom_url, body)
    end
  end

  def fetched_atom_feed
    @_fetched_atom_feed ||= FetchAtomService.new.call(url)
  end

  def atom_url
    fetched_atom_feed.first
  end

  def body
    fetched_atom_feed.last
  end

  def xml_root
    xml_data.root.name
  end

  def xml_data
    @_xml_data ||= Nokogiri::XML(body, nil, 'utf-8')
  end
end
