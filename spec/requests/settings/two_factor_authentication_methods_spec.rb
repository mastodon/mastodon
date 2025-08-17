# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings TwoFactorAuthenticationMethods' do
  context 'when not signed in' do
    describe 'GET to /settings/two_factor_authentication_methods' do
      it 'redirects to sign in page' do
        get settings_two_factor_authentication_methods_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end
  end

  context 'when signed in' do
    let(:user) { Fabricate(:user) }

    before { sign_in user }

    describe 'GET to /settings/two_factor_authentication_methods' do
      describe 'when user has not enabled otp' do
        before { user.update(otp_required_for_login: false) }

        it 'redirects to enable otp' do
          get settings_two_factor_authentication_methods_path

          expect(response)
            .to redirect_to(settings_otp_authentication_path)
        end
      end
    end
  end
end
