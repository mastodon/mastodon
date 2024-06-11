# frozen_string_literal: true

require 'rails_helper'

describe Admin::InvitesController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    subject { get :index, params: { available: true } }

    let!(:invite) { Fabricate(:invite) }

    it 'renders index page' do
      expect(subject).to render_template :index
      expect(assigns(:invites)).to include invite
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { invite: { max_uses: '10', expires_in: 1800 } } }

    it 'succeeds to create a invite' do
      expect { subject }.to change(Invite, :count).by(1)
      expect(subject).to redirect_to admin_invites_path
      expect(Invite.last).to have_attributes(user_id: user.id, max_uses: 10)
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { id: invite.id } }

    let!(:invite) { Fabricate(:invite, expires_at: nil) }

    it 'expires invite' do
      expect(subject).to redirect_to admin_invites_path
      expect(invite.reload).to be_expired
    end
  end

  describe 'POST #deactivate_all' do
    it 'expires all invites, then redirects to admin_invites_path' do
      invites = Fabricate.times(2, :invite, expires_at: nil)

      post :deactivate_all

      invites.each do |invite|
        expect(invite.reload).to be_expired
      end

      expect(response).to redirect_to admin_invites_path
    end
  end
end
