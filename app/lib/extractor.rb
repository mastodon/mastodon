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

module Extractor
  extend Twitter::Extractor

  module_function

  def extract_mentions_or_lists_with_indices(text) # :yields: username, list_slug, start, end
    return [] unless text =~ Twitter::Regex[:at_signs]

    possible_entries = []

    text.to_s.scan(Account::MENTION_RE) do |screen_name, _|
      match_data = $LAST_MATCH_INFO
      after = $'
      unless after =~ Twitter::Regex[:end_mention_match]
        start_position = match_data.char_begin(1) - 1
        end_position = match_data.char_end(1)
        possible_entries << {
          screen_name: screen_name,
          indices: [start_position, end_position],
        }
      end
    end

    if block_given?
      possible_entries.each do |mention|
        yield mention[:screen_name], mention[:indices].first, mention[:indices].last
      end
    end
    possible_entries
  end
end
