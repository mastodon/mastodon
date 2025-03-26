# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Deletes' do
  describe 'Deleting user from settings area' do
    let(:user) { Fabricate(:user) }

    before { sign_in(user) }

    it 'requires password and deletes user record', :inline_jobs do
      visit settings_delete_path
      expect(page)
        .to have_title(I18n.t('settings.delete'))
        .and have_private_cache_control

      # Wrong confirmation value
      fill_in 'form_delete_confirmation_password', with: 'wrongvalue'
      click_on I18n.t('deletes.proceed')
      expect(page)
        .to have_content(I18n.t('deletes.challenge_not_passed'))

      # Correct confirmation value
      fill_in 'form_delete_confirmation_password', with: user.password
      click_on I18n.t('deletes.proceed')
      expect(page)
        .to have_content(I18n.t('deletes.success_msg'))
      expect(page)
        .to have_title(I18n.t('auth.login'))
      expect(User.find_by(id: user.id))
        .to be_nil
      expect(user.account.reload)
        .to be_suspended
      expect(CanonicalEmailBlock.block?(user.email))
        .to be(false)
    end
  end
end
