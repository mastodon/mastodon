# frozen_string_literal: true

require 'rails_helper'

describe InvitesController do
  render_views

  let(:user) { Fabricate(:user) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    before do
      Fabricate(:invite, user: user)
    end

    context 'when everyone can invite' do
      before do
        UserRole.everyone.update(permissions: UserRole.everyone.permissions | UserRole::FLAGS[:invite_users])
        get :index
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns private cache control headers' do
        expect(response.headers['Cache-Control']).to include('private, no-store')
      end
    end

    context 'when not everyone can invite' do
      before do
        UserRole.everyone.update(permissions: UserRole.everyone.permissions & ~UserRole::FLAGS[:invite_users])
        get :index
      end

      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { invite: { max_uses: '10', expires_in: 1800 } } }

    context 'when everyone can invite' do
      before do
        UserRole.everyone.update(permissions: UserRole.everyone.permissions | UserRole::FLAGS[:invite_users])
      end

      it 'succeeds to create a invite' do
        expect { subject }.to change(Invite, :count).by(1)
        expect(subject).to redirect_to invites_path
        expect(Invite.last).to have_attributes(user_id: user.id, max_uses: 10)
      end
    end

    context 'when not everyone can invite' do
      before do
        UserRole.everyone.update(permissions: UserRole.everyone.permissions & ~UserRole::FLAGS[:invite_users])
      end

      it 'returns http forbidden' do
        expect(subject).to have_http_status(403)
      end
    end
  end

  describe 'DELETE #create' do
    let(:invite) { Fabricate(:invite, user: user, expires_at: nil) }

    before do
      delete :destroy, params: { id: invite.id }
    end

    it 'redirects' do
      expect(response).to redirect_to invites_path
    end

    it 'expires invite' do
      expect(invite.reload).to be_expired
    end
  end
end
