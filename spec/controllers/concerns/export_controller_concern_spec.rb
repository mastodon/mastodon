# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  controller do
    include ExportControllerConcern
    def index
      send_export_file
    end
    def export_data
      @export.account.username
    end
  end

  describe 'GET #index' do
    it 'returns a csv of the exported data when signed in' do
      user = Fabricate(:user)
      sign_in user
      get :index, format: :csv

      expect(response).to have_http_status(200)
      expect(response.content_type).to eq 'text/csv'
      expect(response.headers['Content-Disposition']).to eq 'attachment; filename="anonymous.csv"'
      expect(response.body).to eq user.account.username
    end

    it 'returns unauthorized when not signed in' do
      get :index, format: :csv
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
