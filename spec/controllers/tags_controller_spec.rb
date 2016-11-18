require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  render_views

  describe 'GET #show' do
    before do
      Fabricate(:tag, name: 'test')
    end

    it 'returns http success' do
      get :show, params: { id: 'test' }
      expect(response).to have_http_status(:success)
    end
  end
end
