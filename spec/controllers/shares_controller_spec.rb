require 'rails_helper'

describe SharesController do
  render_views

  let(:user) { Fabricate(:user) }
  before { sign_in user }

  describe 'GTE #show' do
    subject(:initial_state_json) { JSON.parse(assigns(:initial_state_json), symbolize_names: true) }
    subject(:body_classes) { assigns(:body_classes) }

    before { get :show, params: { title: 'test title', text: 'test text', url: 'url1 url2' } }

    it 'assigns json' do
      expect(response).to have_http_status :ok
      expect(initial_state_json[:compose][:text]).to eq 'test title test text url1 url2'
      expect(initial_state_json[:meta][:me]).to eq user.account.id.to_s
      expect(body_classes).to eq 'modal-layout compose-standalone'
    end
  end
end
