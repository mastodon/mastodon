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

class LanguageDetector
  attr_reader :text, :account

  def initialize(text, account = nil)
    @text = text
    @account = account
  end

  def to_iso_s
    detected_language_code || default_locale.to_sym
  end

  private

  def detected_language_code
    detected_language[:code].to_sym if detected_language_reliable?
  end

  def detected_language
    @_detected_language ||= CLD.detect_language(text_without_urls)
  end

  def detected_language_reliable?
    detected_language[:reliable]
  end

  def text_without_urls
    text.dup.tap do |new_text|
      URI.extract(new_text).each do |url|
        new_text.gsub!(url, '')
      end
    end
  end

  def default_locale
    account&.user_locale || I18n.default_locale
  end
end
