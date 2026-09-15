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
end
