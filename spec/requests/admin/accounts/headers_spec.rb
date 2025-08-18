# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Accounts Headers' do
  before { sign_in current_user }

  describe 'DELETE #destroy' do
    subject { delete "/admin/accounts/#{account.id}/header" }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account, header: fixture_file_upload('attachment.jpg', 'image/jpeg')) }

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in removing header' do
        expect { subject }
          .to change { account.reload.header_file_name }.to(be_blank)
          .and change(Admin::ActionLog, :count).by(1)
        expect(response)
          .to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to remove header' do
        subject

        expect(response)
          .to have_http_status 403
      end
    end
  end
end
