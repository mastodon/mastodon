# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Accounts Header' do
  before { sign_in user }

  let(:user) { Fabricate(:admin_user) }

  describe 'Deleting an account header' do
    let(:account) { Fabricate(:account, header: fixture_file_upload('attachment.jpg', 'image/jpeg')) }

    it 'succeeds in removing header' do
      visit admin_account_path(account.id)

      expect { submit_delete }
        .to change { account.reload.header_file_name }.to(be_blank)
        .and change(Admin::ActionLog, :count).by(1)
      expect(page)
        .to have_content I18n.t('admin.accounts.removed_header_msg', username: account.acct)
    end

    def submit_delete
      click_on I18n.t('admin.accounts.remove_header')
    end
  end
end
