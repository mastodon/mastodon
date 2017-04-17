require 'rails_helper'

RSpec.describe Api::Activitypub::OutboxController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }

  describe 'GET #show' do
    it 'returns http success' do
      @request.env['HTTP_ACCEPT'] = 'application/activity+json'
      get :show, id: user.account.id
      expect(response).to have_http_status(:success)
      expect(response.header['Content-Type']).to include 'application/activity+json'
    end
  end
end
