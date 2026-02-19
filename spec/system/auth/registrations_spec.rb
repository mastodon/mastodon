# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth Registration' do
  context 'when there are server rules' do
    let!(:rule) { Fabricate :rule, text: 'You must be seven meters tall' }

    it 'shows rules page before proceeding with sign up' do
      visit new_user_registration_path
      expect(page)
        .to have_title(I18n.t('auth.register'))
        .and have_content(rule.text)
    end
  end

  context 'when age verification is enabled' do
    before { Setting.min_age = 16 }

    context 'when date of birth is below age limit' do
      let(:date_of_birth) { 13.years.ago }

      it 'does not create user record and displays errors' do
        visit new_user_registration_path
        expect(page)
          .to have_title(I18n.t('auth.register'))

        expect { fill_in_and_submit_form }
          .to not_change(User, :count)
        expect(page)
          .to have_content(/error below/)
      end
    end

    context 'when date of birth is above age limit' do
      let(:date_of_birth) { 17.years.ago }

      it 'creates user and marks as verified' do
        visit new_user_registration_path
        expect(page)
          .to have_title(I18n.t('auth.register'))

        expect { fill_in_and_submit_form }
          .to change(User, :count).by(1)
        expect(User.last)
          .to have_attributes(email: 'test@example.com', age_verified_at: be_present)
        expect(page)
          .to have_content(I18n.t('auth.setup.title'))
      end
    end

    def fill_in_and_submit_form
      # Avoid the registration spam check
      travel_to 10.seconds.from_now

      fill_in 'user_account_attributes_username', with: 'test'
      fill_in 'user_email', with: 'test@example.com'
      fill_in 'user_password', with: 'Test.123.Pass'
      fill_in 'user_password_confirmation', with: 'Test.123.Pass'
      check 'user_agreement'

      find('input[aria-label="Day"]').fill_in with: date_of_birth.day
      find('input[autocomplete="bday-month"]').fill_in with: date_of_birth.month
      find('input[autocomplete="bday-year"]').fill_in with: date_of_birth.year

      click_on I18n.t('auth.register')
    end
  end
end
