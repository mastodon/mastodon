# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth Registration' do
  context 'when there are server rules' do
    let!(:rule) { Fabricate :rule, text: 'You must be seven meters tall' }
    let!(:rule_translation) { Fabricate :rule_translation, rule:, hint: 'Rule translation hint', text: rule.text }
    let(:invite) { Fabricate :invite, autofollow: true }

    it 'shows rules page before proceeding with sign up' do
      visit new_user_registration_path(invite_code: invite.code)
      expect(page)
        .to have_title(I18n.t('auth.register'))
        .and have_text(rule.text)
        .and have_text(rule_translation.hint)

      click_on I18n.t('auth.rules.accept')
      expect(page)
        .to have_text(I18n.t('auth.sign_up.preamble'))
        .and have_text(I18n.t('invites.invited_by'))
    end
  end

  context 'when an invite code was previously followed' do
    let(:older_invite) { Fabricate :invite, autofollow: true }
    let(:invite) { Fabricate :invite, autofollow: true }

    before { visit new_user_registration_path(invite_code: older_invite.code) }

    it 'honors the newer invitation' do
      visit new_user_registration_path(invite_code: invite.code)
      expect(page)
        .to have_text(I18n.t('invites.invited_by'))
        .and have_text(invite.user.account.username)
    end
  end

  context 'with approval-based registrations' do
    subject { visit new_user_registration_path }

    shared_examples 'approval is required' do
      context 'when reason to join is not required' do
        before { Setting.require_invite_text = false }

        it 'asks for an optional reason to join, creates the user as unapproved' do
          subject

          expect(page)
            .to have_title(I18n.t('auth.register'))

          expect(page)
            .to have_text(I18n.t('simple_form.labels.invite_request.text'))

          expect { fill_in_and_submit_form(apply: true) }
            .to change(User, :count).by(1)

          expect(User.find_by(email: 'test@example.com'))
            .to have_attributes(approved: false)
        end
      end

      context 'when reason to join is required' do
        before { Setting.require_invite_text = true }

        it 'asks for a required reason to join, creates the user unapproved' do
          subject

          expect(page)
            .to have_title(I18n.t('auth.register'))

          expect(page)
            .to have_text(I18n.t('simple_form.labels.invite_request.text'))

          # Not providing the invite text results in an error
          expect { fill_in_and_submit_form(apply: true) }
            .to_not change(User, :count)
          expect(page)
            .to have_text(/error below/)

          # Providing the invite text succeeds
          expect { fill_in_and_submit_form(apply: true, invite_text: 'Hello world') }
            .to change(User, :count).by(1)

          expect(User.find_by(email: 'test@example.com'))
            .to have_attributes(approved: false)
        end
      end
    end

    before do
      Setting.registrations_mode = 'approved'
    end

    it_behaves_like 'approval is required'

    context 'with an invitation' do
      subject { visit new_user_registration_path(invite_code: invite.code) }

      let!(:inviter) { Fabricate(:user, confirmed_at: 2.days.ago, bypass_registration_checks: true) }
      let(:invite) { Fabricate(:invite, user: inviter) }

      before do
        inviter.approve!
      end

      it_behaves_like 'approval is required'

      context 'when the invite allows bypassing approval' do
        before do
          inviter.role.update!(permissions: inviter.role.permissions | UserRole::FLAGS[:invite_bypass_approval])
        end

        it 'does not ask for a required reason to join, creates the user approved' do
          subject

          expect(page)
            .to have_title(I18n.t('auth.register'))

          expect(page)
            .to have_no_text(I18n.t('simple_form.labels.invite_request.text'))

          expect { fill_in_and_submit_form(apply: false) }
            .to change(User, :count).by(1)

          expect(User.find_by(email: 'test@example.com'))
            .to have_attributes(approved: true)
        end
      end

      context 'when invite has expired' do
        let(:invite) { Fabricate(:invite, user: inviter, expires_at: 1.hour.ago) }

        it_behaves_like 'approval is required'
      end
    end

    def fill_in_and_submit_form(apply: false, invite_text: nil)
      # Avoid the registration spam check
      travel_to 10.seconds.from_now

      fill_in 'user_account_attributes_username', with: 'test'
      fill_in 'user_email', with: 'test@example.com'
      fill_in 'user_password', with: 'Test.123.Pass'
      fill_in 'user_password_confirmation', with: 'Test.123.Pass'
      fill_in 'user_invite_request_attributes_text', with: invite_text if invite_text.present?
      check 'user_agreement'

      click_on(apply ? I18n.t('auth.apply_for_account') : I18n.t('auth.register'))
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
          .to have_text(/error below/)
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
          .to have_text(I18n.t('auth.setup.title'))
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
