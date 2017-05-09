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

module Admin
  class SettingsController < BaseController
    ADMIN_SETTINGS = %w(
      site_contact_username
      site_contact_email
      site_title
      site_description
      site_extended_description
      open_registrations
      closed_registrations_message
    ).freeze
    BOOLEAN_SETTINGS = %w(open_registrations).freeze

    def edit
      @settings = Setting.all_as_records
    end

    def update
      settings_params.each do |key, value|
        setting = Setting.where(var: key).first_or_initialize(var: key)
        setting.update(value: value_for_update(key, value))
      end

      flash[:notice] = 'Success!'
      redirect_to edit_admin_settings_path
    end

    private

    def settings_params
      params.permit(ADMIN_SETTINGS)
    end

    def value_for_update(key, value)
      if BOOLEAN_SETTINGS.include?(key)
        value == 'true'
      else
        value
      end
    end
  end
end
