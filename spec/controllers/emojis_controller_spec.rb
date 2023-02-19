require 'rails_helper'

describe EmojisController do
  render_views

  let(:emoji) { Fabricate(:custom_emoji) }

  describe 'GET #show' do
    subject(:response) { get :show, params: { id: emoji.id, format: :json } }

    subject(:body) { JSON.parse(response.body, symbolize_names: true) }

    it 'returns the right response' do
      expect(response).to have_http_status 200
      expect(body[:name]).to eq ':coolcat:'
    end
  end
end
