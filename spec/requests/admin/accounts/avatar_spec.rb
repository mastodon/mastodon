# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Accounts Avatar' do
  before { sign_in user }

  describe 'DELETE #destroy' do
    let(:user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account, avatar: fixture_file_upload('avatar.gif', 'image/gif')) }

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to remove avatar' do
        delete "/admin/accounts/#{account.id}/avatar"

        expect(response)
          .to have_http_status 403
      end
    end
  end
end
