# frozen_string_literal: true

require 'rails_helper'
require 'webauthn/fake_client'

RSpec.describe 'Admin Users TwoFactorAuthentications' do
  let(:user) { Fabricate(:user) }

  before { sign_in Fabricate(:admin_user) }

  describe 'Disabling 2FA for users' do
    before { stub_webauthn_credential }

    let(:fake_client) { WebAuthn::FakeClient.new('http://test.host') }

    context 'when user has OTP enabled' do
      before { user.update(otp_required_for_login: true) }

      it 'disables OTP and redirects to admin account page' do
        visit admin_account_path(user.account.id)

        expect { disable_two_factor }
          .to change { user.reload.otp_enabled? }.to(false)
        expect(page)
          .to have_title(user.account.pretty_acct)
      end
    end

    context 'when user has OTP and WebAuthn enabled' do
      before { user.update(otp_required_for_login: true, webauthn_id: WebAuthn.generate_user_id) }

      it 'disables OTP and webauthn and redirects to admin account page' do
        visit admin_account_path(user.account.id)

        expect { disable_two_factor }
          .to change { user.reload.otp_enabled? }.to(false)
          .and(change { user.reload.webauthn_enabled? }.to(false))
        expect(page)
          .to have_title(user.account.pretty_acct)
      end
    end

    def disable_two_factor
      click_on I18n.t('admin.accounts.disable_two_factor_authentication')
    end

    def stub_webauthn_credential
      public_key_credential = WebAuthn::Credential.from_create(fake_client.create)
      Fabricate(
        :webauthn_credential,
        external_id: public_key_credential.id,
        nickname: 'Security Key',
        public_key: public_key_credential.public_key,
        user_id: user.id
      )
    end
  end
end
