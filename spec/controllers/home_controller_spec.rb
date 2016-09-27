require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    it 'redirects to about page' do
      get :index
      expect(response).to redirect_to(about_path)
    end
  end
end
