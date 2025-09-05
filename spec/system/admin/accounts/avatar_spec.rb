# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Accounts Avatar' do
  before { sign_in user }

  let(:user) { Fabricate(:admin_user) }

  describe 'Deleting an account avatar' do
    let(:account) { Fabricate(:account, avatar: fixture_file_upload('avatar.gif', 'image/gif')) }

    it 'succeeds in removing avatar' do
      visit admin_account_path(account.id)

      expect { submit_delete }
        .to change { account.reload.avatar_file_name }.to(be_blank)
        .and change(Admin::ActionLog, :count).by(1)
      expect(page)
        .to have_content I18n.t('admin.accounts.removed_avatar_msg', username: account.acct)
    end

    def submit_delete
      click_on I18n.t('admin.accounts.remove_avatar')
    end
  end
end
