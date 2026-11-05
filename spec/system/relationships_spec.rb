# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Relationships' do
  let(:user) { Fabricate(:user) }
  let(:account) { Fabricate(:account, username: 'alice', domain: 'example.com') }

  before { sign_in user }

  describe 'Viewing relationships' do
    before { user.account.follow!(account) }

    it 'shows followed accounts with private cache control headers' do
      visit relationships_path

      expect(page)
        .to have_title(I18n.t('settings.relationships'))
        .and have_text(account.acct)
        .and have_private_cache_control
    end
  end

  describe 'Removing followers from selected domains' do
    before do
      account.follow!(user.account)
      user.account.follow!(account)
    end

    it 'removes followers without unfollowing them' do
      visit relationships_path

      click_on I18n.t('relationships.followers')
      batch_checkbox_for(account).check

      expect { click_on I18n.t('relationships.remove_selected_domains') }
        .to change { user.account.followers.exists?(account.id) }.from(true).to(false)
        .and(not_change { user.account.following.exists?(account.id) })

      expect(page)
        .to have_title(I18n.t('settings.relationships'))
        .and have_no_text(account.acct)
    end
  end

  private

  def batch_checkbox_for(account)
    find("#form_account_batch_account_ids_#{account.id}")
  end
end
