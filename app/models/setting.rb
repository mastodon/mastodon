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
# == Schema Information
#
# Table name: settings
#
#  id         :integer          not null, primary key
#  var        :string           not null
#  value      :text
#  thing_type :string
#  thing_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class Setting < RailsSettings::Base
  source Rails.root.join('config/settings.yml')

  def to_param
    var
  end

  class << self
    def [](key)
      return super(key) unless rails_initialized?

      val = Rails.cache.fetch(cache_key(key, @object)) do
        db_val = object(key)

        if db_val
          default_value = default_settings[key]

          return default_value.with_indifferent_access.merge!(db_val.value) if default_value.is_a?(Hash)
          db_val.value
        else
          default_settings[key]
        end
      end

      val
    end

    def all_as_records
      vars    = thing_scoped
      records = vars.map { |r| [r.var, r] }.to_h

      default_settings.each do |key, default_value|
        next if records.key?(key) || default_value.is_a?(Hash)
        records[key] = Setting.new(var: key, value: default_value)
      end

      records
    end

    private

    def default_settings
      return {} unless RailsSettings::Default.enabled?
      RailsSettings::Default.instance
    end
  end
end
