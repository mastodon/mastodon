# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::FollowedTagsController, type: :controller do
  render_views

  let(:user)   { Fabricate(:user) }
  let(:scopes) { 'read:follows' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  before { allow(controller).to receive(:doorkeeper_token) { token } }

  describe 'GET #index' do
    let!(:tag_follows) { Fabricate.times(5, :tag_follow, account: user.account) }

    before do
      get :index, params: { limit: 1 }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
