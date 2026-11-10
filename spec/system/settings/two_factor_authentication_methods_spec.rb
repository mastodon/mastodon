# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings TwoFactorAuthenticationMethods' do
  context 'when signed in' do
    let(:user) { Fabricate(:user) }

    before { sign_in user }

    describe 'Managing 2FA methods' do
      before { user.update(otp_required_for_login: true) }

      it 'disables 2FA with challenge confirmation', :inline_jobs do
        visit settings_two_factor_authentication_methods_path
        expect(page)
          .to have_text(I18n.t('settings.two_factor_authentication'))
          .and have_private_cache_control

        # Attempt to disable
        click_on I18n.t('two_factor_authentication.disable')
        expect(page)
          .to have_title(I18n.t('challenge.prompt'))

        # Fill in challenge form
        fill_in 'form_challenge_current_password', with: user.password
        expect { click_on I18n.t('challenge.confirm') }
          .to change { user.reload.otp_required_for_login }.to(false)
          .and send_email(to: user.email, subject: I18n.t('devise.mailer.two_factor_disabled.subject'))

        expect(page)
          .to have_text(I18n.t('two_factor_authentication.disabled_success'))
      end
    end

    describe 'Removing the methods one at a time' do
      before do
        user.update(otp_required_for_login: true, otp_secret: User.generate_otp_secret(32), webauthn_id: WebAuthn.generate_user_id)
        user.generate_otp_backup_codes!
        user.save!
        Fabricate(:webauthn_credential, user_id: user.id, nickname: 'USB key')
      end

      it 'clears the recovery codes once the last method is gone', :inline_jobs do
        # Remove the security key while the authenticator app is still enabled
        visit settings_webauthn_credentials_path
        expect { click_on I18n.t('webauthn_credentials.delete') }
          .to(not_change { user.reload.otp_backup_codes })

        expect(page)
          .to have_text(I18n.t('two_factor_authentication.recovery_codes'))

        # Remove the authenticator app, the last remaining method
        click_on I18n.t('otp_authentication.delete')
        expect(page)
          .to have_title(I18n.t('challenge.prompt'))

        fill_in 'form_challenge_current_password', with: user.password
        expect { click_on I18n.t('challenge.confirm') }
          .to change { user.reload.otp_backup_codes }.to(be_empty)
          .and change { user.reload.otp_required_for_login }.to(false)
          .and send_email(to: user.email, subject: I18n.t('devise.mailer.two_factor_disabled.subject'))

        expect(page)
          .to have_no_text(I18n.t('two_factor_authentication.recovery_codes'))
      end
    end
  end
end
