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

module Settings
  class TwoFactorAuthenticationsController < ApplicationController
    layout 'admin'

    before_action :authenticate_user!
    before_action :verify_otp_required, only: [:create]

    def show; end

    def create
      current_user.otp_secret = User.generate_otp_secret(32)
      current_user.save!
      redirect_to new_settings_two_factor_authentication_confirmation_path
    end

    def destroy
      current_user.otp_required_for_login = false
      current_user.save!
      redirect_to settings_two_factor_authentication_path
    end

    private

    def verify_otp_required
      redirect_to settings_two_factor_authentication_path if current_user.otp_required_for_login?
    end
  end
end
