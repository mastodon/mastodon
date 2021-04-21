require 'rails_helper'

describe WellKnown::KeybaseProofConfigController, type: :controller do
  render_views

  describe 'GET #show' do
    it 'renders json' do
      get :show

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/json'
      expect { JSON.parse(response.body) }.not_to raise_exception
    end
  end
end
