# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings TwoFactorAuthentication RecoveryCodes' do
  describe 'Generating recovery codes' do
    let(:user) { Fabricate :user, otp_required_for_login: true }
    let(:backup_code) { +'147e7284c95bd260b91ed17820860019' }

    before do
      stub_code_generator
      sign_in(user)
    end

    it 'updates the codes and includes them in the view' do
      # Attempt to generate codes
      visit settings_two_factor_authentication_methods_path
      click_on I18n.t('two_factor_authentication.generate_recovery_codes')

      # Fill in challenge password
      fill_in 'form_challenge_current_password', with: user.password

      expect { click_on I18n.t('challenge.confirm') }
        .to(change { user.reload.otp_backup_codes })

      expect(page)
        .to have_content(I18n.t('two_factor_authentication.recovery_codes_regenerated'))
        .and have_title(I18n.t('settings.two_factor_authentication'))
        .and have_css('ol.recovery-codes')
        .and have_content(backup_code)
    end

    def stub_code_generator
      allow(SecureRandom).to receive(:hex).and_return(backup_code)
    end
  end
end
