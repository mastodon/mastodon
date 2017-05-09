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

module AccountAvatar
  extend ActiveSupport::Concern
  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze

  class_methods do
    def avatar_styles(file)
      styles = { original: '120x120#' }
      styles[:static] = { format: 'png' } if file.content_type == 'image/gif'
      styles
    end
    private :avatar_styles
  end

  included do
    # Avatar upload
    has_attached_file :avatar, styles: ->(f) { avatar_styles(f) }, convert_options: { all: '-quality 80 -strip' }
    validates_attachment_content_type :avatar, content_type: IMAGE_MIME_TYPES
    validates_attachment_size :avatar, less_than: 2.megabytes

    def avatar_original_url
      avatar.url(:original)
    end

    def avatar_static_url
      avatar_content_type == 'image/gif' ? avatar.url(:static) : avatar_original_url
    end

    def avatar_remote_url=(url)
      parsed_url = Addressable::URI.parse(url).normalize

      return if !%w(http https).include?(parsed_url.scheme) || parsed_url.host.empty? || self[:avatar_remote_url] == url

      self.avatar              = URI.parse(parsed_url.to_s)
      self[:avatar_remote_url] = url
    rescue OpenURI::HTTPError => e
      Rails.logger.debug "Error fetching remote avatar: #{e}"
    end
  end
end
