require 'rails_helper'

describe HealthController do
  render_views

  describe 'GET #show' do
    subject(:response) { get :show, params: { format: :json } }

    it 'returns the right response' do
      expect(response).to have_http_status 200
    end
  end
end
