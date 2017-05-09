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

module Streamable
  extend ActiveSupport::Concern

  included do
    has_one :stream_entry, as: :activity

    def title
      super
    end

    def content
      title
    end

    def target
      super
    end

    def object_type
      :activity
    end

    def thread
      super
    end

    def hidden?
      false
    end

    def needs_stream_entry?
      account.local?
    end

    after_create do
      account.stream_entries.create!(activity: self, hidden: hidden?) if needs_stream_entry?
    end
  end
end
