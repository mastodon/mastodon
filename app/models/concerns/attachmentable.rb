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

module Attachmentable
  extend ActiveSupport::Concern

  included do
    before_post_process :set_file_extensions
  end

  private

  def set_file_extensions
    self.class.attachment_definitions.each_key do |attachment_name|
      attachment = send(attachment_name)
      next if attachment.blank?
      extension = Paperclip::Interpolations.content_type_extension(attachment, :original)
      basename  = Paperclip::Interpolations.basename(attachment, :original)
      attachment.instance_write :file_name, [basename, extension].delete_if(&:blank?).join('.')
    end
  end
end
