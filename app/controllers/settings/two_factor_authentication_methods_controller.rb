# frozen_string_literal: true

module Settings
  class TwoFactorAuthenticationMethodsController < BaseController
    include ChallengableConcern

    layout 'admin'

    before_action :authenticate_user!
    before_action :require_otp_enabled

    skip_before_action :require_functional!

    def index; end

    private

    def require_otp_enabled
      redirect_to settings_otp_authentication_path unless current_user.otp_enabled?
    end
  end
end
