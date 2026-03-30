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

    fill_in_auth_details(email, password)

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
