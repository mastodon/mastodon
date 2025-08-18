# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Accounts Header' do
  before { sign_in user }

  describe 'DELETE #destroy' do
    let(:user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account, header: fixture_file_upload('attachment.jpg', 'image/jpeg')) }

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to remove header' do
        delete "/admin/accounts/#{account.id}/header"

        expect(response)
          .to have_http_status 403
      end
    end
  end
end
