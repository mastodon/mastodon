# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Accounts::AvatarsController do
  render_views

  before { sign_in current_user }

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { account_id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account) }

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in removing avatar' do
        expect(subject).to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to remove avatar' do
        expect(subject).to have_http_status 403
      end
    end
  end
end
