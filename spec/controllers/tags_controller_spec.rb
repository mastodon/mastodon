require 'rails_helper'

RSpec.describe TagsController, type: :controller do

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: 'test' }
      expect(response).to have_http_status(:success)
    end
  end

end
