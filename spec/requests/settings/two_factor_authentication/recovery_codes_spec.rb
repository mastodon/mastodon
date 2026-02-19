# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings TwoFactorAuthentication RecoveryCodes' do
  describe 'POST /settings/two_factor_authentication/recovery_codes' do
    context 'when signed out' do
      it 'redirects to sign in page' do
        post settings_two_factor_authentication_recovery_codes_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end
  end
end
