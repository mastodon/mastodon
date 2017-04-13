require 'rails_helper'

describe WellKnown::HostMetaController, type: :controller do
  render_views

  describe 'GET #show' do
    it 'returns http success' do
      get :show, format: :xml

      expect(response).to have_http_status(:success)
    end
  end
end
