# frozen_string_literal: true

module Settings
  module TwoFactorAuthentication
    class RecoveryCodesController < BaseController
      include ChallengableConcern

      layout 'admin'

      before_action :authenticate_user!
      before_action :require_challenge!, on: :create

      skip_before_action :require_functional!

      def create
        @recovery_codes = current_user.generate_otp_backup_codes!
        current_user.save!

        UserMailer.two_factor_recovery_codes_changed(current_user).deliver_later!
        flash.now[:notice] = I18n.t('two_factor_authentication.recovery_codes_regenerated')

        render :index
      end
    end
  end
end
