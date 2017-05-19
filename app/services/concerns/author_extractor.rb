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

module AuthorExtractor
  def author_from_xml(xml)
    # Try <email> for acct
    acct = xml.at_xpath('./xmlns:author/xmlns:email', xmlns: TagManager::XMLNS)&.content

    # Try <name> + <uri>
    if acct.blank?
      username = xml.at_xpath('./xmlns:author/xmlns:name', xmlns: TagManager::XMLNS)&.content
      uri      = xml.at_xpath('./xmlns:author/xmlns:uri', xmlns: TagManager::XMLNS)&.content

      return nil if username.blank? || uri.blank?

      domain = Addressable::URI.parse(uri).normalize.host
      acct   = "#{username}@#{domain}"
    end

    FollowRemoteAccountService.new.call(acct)
  end
end
