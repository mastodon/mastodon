# frozen_string_literal: true

require 'rails_helper'

describe Admin::InvitesController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    let!(:invite) { Fabricate(:invite) }

    it 'renders index page' do
      get :index, params: { available: true }

      expect(response)
        .to have_http_status(200)
        .and render_template(:index)

      expect(assigns(:invites))
        .to include invite
    end
  end

  describe 'POST #create' do
    it 'succeeds to create a invite' do
      expect do
        post :create, params: { invite: { max_uses: '10', expires_in: 1800 } }
      end.to change(Invite, :count).by(1)

      expect(response)
        .to redirect_to admin_invites_path

      expect(Invite.last)
        .to have_attributes(user_id: user.id, max_uses: 10)
    end
  end

  describe 'DELETE #destroy' do
    let!(:invite) { Fabricate(:invite, expires_at: nil) }

    it 'expires invite' do
      delete :destroy, params: { id: invite.id }

      expect(response)
        .to redirect_to admin_invites_path

      expect(invite.reload)
        .to be_expired
    end
  end

  describe 'POST #deactivate_all' do
    it 'expires all invites, then redirects to admin_invites_path' do
      invites = Fabricate.times(1, :invite, expires_at: nil)

      post :deactivate_all

      expect(invites.each(&:reload))
        .to all(be_expired)

      expect(response)
        .to redirect_to admin_invites_path
    end
  end
end
