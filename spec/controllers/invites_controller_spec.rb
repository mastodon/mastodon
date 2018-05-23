require 'rails_helper'

describe InvitesController do
  render_views

  before do
    sign_in user
  end

  describe 'GET #index' do
    subject { get :index }

    let!(:invite) { Fabricate(:invite, user: user) }

    context 'when user is a staff' do
      let(:user) { Fabricate(:user, moderator: true, admin: false) }

      it 'renders index page' do
        expect(subject).to render_template :index
        expect(assigns(:invites)).to include invite
        expect(assigns(:invites).count).to eq 1
      end
    end

    context 'when user is not a staff' do
      let(:user) { Fabricate(:user, moderator: false, admin: false) }

      it 'returns 403' do
        expect(subject).to have_http_status 403
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { invite: { max_uses: '10', expires_in: 1800 } } }

    context 'when user is an admin' do
      let(:user) { Fabricate(:user, moderator: false, admin: true) }

      it 'succeeds to create a invite' do
        expect{ subject }.to change { Invite.count }.by(1)
        expect(subject).to redirect_to invites_path
        expect(Invite.last).to have_attributes(user_id: user.id, max_uses: 10)
      end
    end

    context 'when user is not an admin' do
      let(:user) { Fabricate(:user, moderator: true, admin: false) }

      it 'returns 403' do
        expect(subject).to have_http_status 403
      end
    end
  end

  describe 'DELETE #create' do
    subject { delete :destroy, params: { id: invite.id } }

    let!(:invite) { Fabricate(:invite, user: user, expires_at: nil) }
    let(:user) { Fabricate(:user, moderator: false, admin: true) }

    it 'expires invite' do
      expect(subject).to redirect_to invites_path
      expect(invite.reload).to be_expired
    end
  end
end
