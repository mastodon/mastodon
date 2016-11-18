require 'rails_helper'

RSpec.describe AboutController, type: :controller do
  render_views

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #terms' do
    it 'returns http success' do
      get :terms
      expect(response).to have_http_status(:success)
    end
  end
end
