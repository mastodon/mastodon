# frozen_string_literal: true

require 'rails_helper'

describe InvitesController do
  render_views

  before do
    sign_in user
  end

  describe 'GET #index' do
    subject { get :index }

    let(:user) { Fabricate(:user) }
    let!(:invite) { Fabricate(:invite, user: user) }

    context 'when everyone can invite' do
      before do
        UserRole.everyone.update(permissions: UserRole.everyone.permissions | UserRole::FLAGS[:invite_users])
      end

      it 'renders index page' do
        expect(subject).to render_template :index
        expect(assigns(:invites)).to include invite
        expect(assigns(:invites).count).to eq 1
      end
    end

    context 'when not everyone can invite' do
      before do
        UserRole.everyone.update(permissions: UserRole.everyone.permissions & ~UserRole::FLAGS[:invite_users])
      end

      it 'returns 403' do
        expect(subject).to have_http_status 403
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { invite: { max_uses: '10', expires_in: 1800 } } }

    context 'when everyone can invite' do
      let(:user) { Fabricate(:user) }

      before do
        UserRole.everyone.update(permissions: UserRole.everyone.permissions | UserRole::FLAGS[:invite_users])
      end

      it 'succeeds to create a invite' do
        expect { subject }.to change { Invite.count }.by(1)
        expect(subject).to redirect_to invites_path
        expect(Invite.last).to have_attributes(user_id: user.id, max_uses: 10)
      end
    end

    context 'when not everyone can invite' do
      let(:user) { Fabricate(:user) }

      before do
        UserRole.everyone.update(permissions: UserRole.everyone.permissions & ~UserRole::FLAGS[:invite_users])
      end

      it 'returns 403' do
        expect(subject).to have_http_status 403
      end
    end
  end

  describe 'DELETE #create' do
    subject { delete :destroy, params: { id: invite.id } }

    let(:user) { Fabricate(:user) }
    let!(:invite) { Fabricate(:invite, user: user, expires_at: nil) }

    it 'expires invite' do
      expect(subject).to redirect_to invites_path
      expect(invite.reload).to be_expired
    end
  end
end
