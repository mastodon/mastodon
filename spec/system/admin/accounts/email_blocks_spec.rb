# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Accounts Email Blocks' do
  before { sign_in user }

  let(:user) { Fabricate(:admin_user) }

  describe 'Deleting email blocks for an account' do
    let(:account) { Fabricate(:account, user: nil) }

    before { Fabricate :canonical_email_block, reference_account: account }

    it 'succeeds in removing header' do
      visit admin_account_path(account.id)

      expect { submit_unblock }
        .to change(CanonicalEmailBlock.where(reference_account: account), :count).by(-1)
      expect(page)
        .to have_content I18n.t('admin.accounts.unblocked_email_msg', username: account.acct)
    end

    def submit_unblock
      click_on I18n.t('admin.accounts.unblock_email')
    end
  end
end
