require 'rails_helper'

describe Settings::ExportsController do

  before do
    sign_in Fabricate(:user), scope: :user
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #download_following_list' do
    it 'returns a csv of the following accounts' do
      get :download_following_list, format: :csv

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq "text/csv"
    end
  end

  describe 'GET #download_blocking_list' do
    it 'returns a csv of the blocking accounts' do
      get :download_blocking_list, format: :csv

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq "text/csv"
    end
  end

end
