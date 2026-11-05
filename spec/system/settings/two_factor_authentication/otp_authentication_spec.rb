# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings OTP Authentication' do
  let(:user) { Fabricate(:user, otp_secret: old_otp_secret, otp_required_for_login: otp_enabled) }
  let(:old_otp_secret) { nil }
  let(:otp_enabled) { false }
  let(:setup_path) { settings_otp_authentication_path }
  let(:setup_button) { I18n.t('otp_authentication.setup') }

  before do
    freeze_time
    sign_in user
  end

  shared_examples 'setting up OTP authentication' do
    it 'confirms the new secret and displays usable recovery codes', :inline_jobs do
      start_setup
      new_secret = displayed_otp_secret

      expect(page.html)
        .to include(qr_code_markup(new_secret))

      fill_in 'form_two_factor_confirmation_otp_attempt', with: ROTP::TOTP.new(new_secret).now

      expect { click_on I18n.t('otp_authentication.enable') }
        .to change { user.reload.otp_secret }.to(new_secret)
        .and(change { user.reload.otp_backup_codes })
        .and(send_email(to: user.email, subject: I18n.t('devise.mailer.two_factor_enabled.subject')))

      expect(user)
        .to be_otp_required_for_login
      expect(page)
        .to have_title(I18n.t('settings.two_factor_authentication'))
        .and have_text(I18n.t('two_factor_authentication.enabled_success'))
        .and have_css('ol.recovery-codes li', count: user.class.otp_number_of_backup_codes)
      expect(user.invalidate_otp_backup_code!(find('ol.recovery-codes li:first-child samp').text))
        .to be true

      visit new_settings_two_factor_authentication_confirmation_path

      expect(page)
        .to have_current_path(settings_two_factor_authentication_methods_path)
    end

    it 'rejects an invalid code without changing the existing OTP configuration' do
      start_setup
      new_secret = displayed_otp_secret

      fill_in 'form_two_factor_confirmation_otp_attempt', with: 'invalid'

      expect { click_on I18n.t('otp_authentication.enable') }
        .to(not_change { [user.reload.otp_secret, user.otp_required_for_login, user.otp_backup_codes] })

      expect(page)
        .to have_title(I18n.t('settings.two_factor_authentication'))
        .and have_css('.flash-message', text: I18n.t('otp_authentication.wrong_code'))
        .and have_field('form_two_factor_confirmation_otp_attempt')
      expect(displayed_otp_secret)
        .to eq(new_secret)
      expect(page.html)
        .to include(qr_code_markup(new_secret))
    end
  end

  context 'without an existing OTP secret' do
    it_behaves_like 'setting up OTP authentication'
  end

  context 'with an existing OTP secret' do
    let(:old_otp_secret) { User.generate_otp_secret }

    it_behaves_like 'setting up OTP authentication'
  end

  context 'with OTP already enabled' do
    let(:old_otp_secret) { User.generate_otp_secret }
    let(:otp_enabled) { true }
    let(:setup_path) { settings_two_factor_authentication_methods_path }
    let(:setup_button) { I18n.t('two_factor_authentication.edit') }

    it_behaves_like 'setting up OTP authentication'
  end

  private

  def start_setup
    visit setup_path
    expect(page)
      .to have_title(I18n.t('settings.two_factor_authentication'))

    click_on setup_button
    expect(page)
      .to have_title(I18n.t('challenge.prompt'))

    fill_in 'form_challenge_current_password', with: user.password
    expect { click_on I18n.t('challenge.confirm') }
      .to(not_change { user.reload.otp_secret })
    expect(page)
      .to have_current_path(new_settings_two_factor_authentication_confirmation_path)
  end

  def displayed_otp_secret
    find('.qr-alternative__code').text.delete(' ')
  end

  def qr_code_markup(secret)
    provisioning_uri = ROTP::TOTP.new(secret, issuer: Rails.configuration.x.local_domain).provisioning_uri(user.email)

    RQRCode::QRCode.new(provisioning_uri).as_svg(padding: 0, module_size: 4, use_path: true)
  end
end
