# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Account Change Email' do
  describe 'PUT /admin/accounts/:account_id/change_email' do
    before { sign_in Fabricate(:admin_user) }

    let(:account) { Fabricate :account }

    it 'gracefully handles invalid nested params' do
      put admin_account_change_email_path(account.id, user: 'invalid')

      expect(response)
        .to have_http_status(400)
    end

    context 'when email is not changed' do
      subject { put admin_account_change_email_path(user.account_id, user: { unconfirmed_email: 'original@host.example' }) }

      let(:user) { Fabricate :user, email: 'original@host.example' }

      it 'does not updated the user record' do
        expect { expect { subject }.to_not send_email }
          .to not_change { user.reload.unconfirmed_email }
          .and(not_change { user.reload.updated_at })
      end
    end
  end
end
