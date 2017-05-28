# frozen_string_literal: true

require 'rails_helper'

describe Settings::Exports::BaseController do
  controller do
    def export_data
      @export.account.username
    end
  end

  describe 'GET #index' do
    it 'returns a csv of the exported data when signed in' do
      user = Fabricate(:user)
      sign_in user
      get :index, format: :csv

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq 'text/csv'
      expect(response.headers['Content-Disposition']).to eq 'attachment; filename="base.csv"'
      expect(response.body).to eq user.account.username
    end

    it 'returns unauthorized when not signed in' do
      get :index, format: :csv
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
