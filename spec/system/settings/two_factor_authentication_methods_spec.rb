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
          .to have_content(I18n.t('settings.two_factor_authentication'))
          .and have_private_cache_control

        # Attempt to disable
        click_on I18n.t('two_factor_authentication.disable')
        expect(page)
          .to have_title(I18n.t('challenge.prompt'))

        # Fill in challenge form
        fill_in 'form_challenge_current_password', with: user.password
        emails = capture_emails do
          expect { click_on I18n.t('challenge.confirm') }
            .to change { user.reload.otp_required_for_login }.to(false)
        end

        expect(page)
          .to have_content(I18n.t('two_factor_authentication.disabled_success'))
        expect(emails.first)
          .to be_present
          .and(deliver_to(user.email))
          .and(have_subject(I18n.t('devise.mailer.two_factor_disabled.subject')))
      end
    end
  end
end
