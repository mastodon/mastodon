# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Automated post deletion settings' do
  let(:user) { Fabricate :user }
  let(:account) { user.account }

  describe 'Updating settings' do
    before { sign_in user }

    it 'visits the page and updates the policy' do
      visit statuses_cleanup_path
      expect(page)
        .to have_private_cache_control

      check I18n.t('statuses_cleanup.enabled')
      submit_form
      expect(account.reload.statuses_cleanup_policy)
        .to be_enabled

      uncheck I18n.t('statuses_cleanup.keep_pinned')
      expect { submit_form }
        .to change { account.reload.statuses_cleanup_policy.keep_pinned? }.to(false)
      expect(page)
        .to have_content(I18n.t('settings.statuses_cleanup'))
    end

    def submit_form
      click_on submit_button
    end
  end
end
