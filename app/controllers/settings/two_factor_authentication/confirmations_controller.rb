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
  module TwoFactorAuthentication
    class ConfirmationsController < ApplicationController
      layout 'admin'

      before_action :authenticate_user!

      def new
        prepare_two_factor_form
      end

      def create
        if current_user.validate_and_consume_otp!(confirmation_params[:code])
          flash[:notice] = I18n.t('two_factor_authentication.enabled_success')

          current_user.otp_required_for_login = true
          @recovery_codes = current_user.generate_otp_backup_codes!
          current_user.save!

          render 'settings/two_factor_authentication/recovery_codes/index'
        else
          flash.now[:alert] = I18n.t('two_factor_authentication.wrong_code')
          prepare_two_factor_form
          render :new
        end
      end

      private

      def confirmation_params
        params.require(:form_two_factor_confirmation).permit(:code)
      end

      def prepare_two_factor_form
        @confirmation = Form::TwoFactorConfirmation.new
        @provision_url = current_user.otp_provisioning_uri(current_user.email, issuer: Rails.configuration.x.local_domain)
        @qrcode = RQRCode::QRCode.new(@provision_url)
      end
    end
  end
end
