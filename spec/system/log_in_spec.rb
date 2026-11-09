# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Log in' do
  include ProfileStories

  subject { page }

  let(:email)        { 'test@example.com' }
  let(:password)     { 'password' }
  let(:confirmed_at) { Time.zone.now }

  before do
    as_a_registered_user
  end

  it 'A valid email and password user is able to log in' do
    visit new_user_session_path

    expect(subject).to have_title(I18n.t('auth.login'))
    expect { fill_in_auth_details(email, password) }
      .to change(bob.login_activities.where(success: true), :count).by(1)

    expect(subject).to have_css('div.app-holder')
  end

  it 'A user is able to log in with an uppercase email' do
    visit new_user_session_path

    fill_in_auth_details(email.upcase, password)

    expect(subject).to have_css('div.app-holder')
  end

  it 'A invalid email and password user is not able to log in' do
    visit new_user_session_path

    fill_in_auth_details('invalid_email', 'invalid_password')

    expect(subject).to have_css('.flash-message', text: /#{failure_message_invalid}/i)
  end

  context 'when confirmed at is nil' do
    let(:confirmed_at) { nil }

    it 'A unconfirmed user is able to log in' do
      visit new_user_session_path

      fill_in_auth_details(email, password)

      expect(subject).to have_css('.title', text: I18n.t('auth.setup.title'))
    end
  end

  context 'with OTP enabled as second factor' do
    before do
      freeze_time
      bob.update!(otp_required_for_login: true, otp_secret: User.generate_otp_secret)
    end

    it 'prompts for a code and logs the user in with a valid OTP' do
      visit new_user_session_path

      fill_in_auth_details(email, password)
      expect(subject)
        .to have_css('p.hint.authentication-hint', text: I18n.t('simple_form.hints.sessions.otp'))
        .and have_no_css('div.app-holder')

      fill_in_otp_details(bob.current_otp)

      expect(subject).to have_css('div.app-holder')
    end

    it 'prompts for a code when using an uppercase email' do
      visit new_user_session_path

      fill_in_auth_details(email.upcase, password)
      expect(subject)
        .to have_css('p.hint.authentication-hint', text: I18n.t('simple_form.hints.sessions.otp'))

      fill_in_otp_details(bob.current_otp)

      expect(subject).to have_css('div.app-holder')
    end

    it 'logs the user in with a valid recovery code' do
      recovery_codes = bob.generate_otp_backup_codes!
      bob.save!
      visit new_user_session_path

      fill_in_auth_details(email, password)
      fill_in_otp_details(recovery_codes.first)

      expect(subject).to have_css('div.app-holder')
    end
  end

  context 'when 2FA is disabled and inactive for long' do
    before { bob.update!(current_sign_in_at: 7.months.ago) }

    it 'sends a sign in token and logs the user in after confirmation', :inline_jobs do
      visit new_user_session_path

      emails = capture_emails do
        expect { fill_in_auth_details(email, password) }
          .to change { bob.reload.sign_in_token }.from(nil)
      end

      expect(subject)
        .to have_css('p.lead', text: I18n.t('users.inactive_sign_in_confirmation'))
        .and have_no_css('div.app-holder')
      expect(emails)
        .to contain_exactly(have_attributes(to: contain_exactly(email), subject: eq(I18n.t('user_mailer.sign_in_token.subject'))))

      fill_in 'user_sign_in_token_attempt', with: bob.sign_in_token
      click_on I18n.t('auth.login')

      expect(subject).to have_css('div.app-holder')
    end

    it 'generates and emails a new token when requested', :inline_jobs do
      visit new_user_session_path
      fill_in_auth_details(email, password)

      emails = capture_emails do
        expect { click_on I18n.t('simple_form.labels.defaults.sign_in_token_resend') }
          .to(change { bob.reload.sign_in_token })
      end

      expect(subject)
        .to have_css('p.lead', text: I18n.t('users.inactive_sign_in_confirmation'))
      expect(emails)
        .to contain_exactly(have_attributes(to: contain_exactly(email), subject: eq(I18n.t('user_mailer.sign_in_token.subject'))))
    end
  end

  context 'when the user role requires 2FA' do
    before do
      bob.role.update!(require_2fa: true)
    end

    context 'when the user has not configured 2FA' do
      it 'they are redirected to 2FA setup' do
        visit new_user_session_path

        fill_in_auth_details(email, password)

        expect(subject).to have_no_css('div.app-holder')
        expect(subject).to have_title(I18n.t('settings.two_factor_authentication'))
      end
    end

    context 'when the user has configured 2FA' do
      before do
        bob.update!(otp_required_for_login: true, otp_secret: User.generate_otp_secret)
      end

      it 'they are able to log in' do
        visit new_user_session_path

        fill_in_auth_details(email, password)
        fill_in_otp_details(bob.current_otp)

        expect(subject).to have_css('div.app-holder')
      end
    end
  end

  private

  def fill_in_otp_details(value)
    fill_in 'user_otp_attempt', with: value
    click_on I18n.t('auth.login')
  end

  def failure_message_invalid
    keys = User.authentication_keys.map { |key| User.human_attribute_name(key) }
    I18n.t('devise.failure.invalid', authentication_keys: keys.join('support.array.words_connector'))
  end
end
