require 'rails_helper'

RSpec.describe StreamEntriesController, type: :controller do
  render_views

  let(:alice)  { Fabricate(:account, username: 'alice') }
  let(:status) { Fabricate(:status, account: alice) }

  describe 'GET #show' do
    it 'returns http success with HTML' do
      get :show, params: { account_username: alice.username, id: status.stream_entry.id }
      expect(response).to have_http_status(:success)
    end

    it 'returns http success with Atom' do
      get :show, params: { account_username: alice.username, id: status.stream_entry.id }, format: 'atom'
      expect(response).to have_http_status(:success)
    end
  end
end
