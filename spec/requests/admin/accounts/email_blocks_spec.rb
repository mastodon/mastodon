# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Accounts Email Blocks' do
  describe 'DELETE /admin/accounts/:account_id/email_blocks' do
    let(:account) { Fabricate(:account, suspended: true) }

    before { Fabricate(:canonical_email_block, reference_account: account) }

    context 'when user is not admin' do
      let(:current_user) { Fabricate(:user, role: UserRole.everyone) }

      it 'fails to unblock email' do
        expect { delete admin_account_email_blocks_path(account_id: account.id) }
          .to_not change(CanonicalEmailBlock.where(reference_account: account), :count)

        expect(response)
          .to have_http_status(403)
      end
    end
  end
end
