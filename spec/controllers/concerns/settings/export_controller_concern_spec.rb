# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::ExportControllerConcern do
  controller(ApplicationController) do
    include Settings::ExportControllerConcern # rubocop:disable RSpec/DescribedClass

    def index
      send_export_file
    end

    def export_data
      'body data value'
    end
  end

  def sign_in_user
    sign_in Fabricate(:user)
  end

  describe 'GET #index' do
    it 'returns a csv of the exported data when signed in' do
      sign_in_user
      get :index, format: :csv

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'text/csv'
      expect(response)
        .to have_attachment('anonymous.csv')
      expect(response.body).to eq 'body data value'
    end

    it 'returns unauthorized when not signed in' do
      get :index, format: :csv
      expect(response).to have_http_status(401)
    end
  end

  context 'when with json format' do
    it 'returns a json of the exported data when signed in' do
      sign_in_user
      get :index, format: :json

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/json'
      expect(response)
        .to have_attachment('anonymous.json')
      expect(response.body).to be_present
    end
  end

  context 'when without format' do
    it 'does not send exported data' do
      sign_in_user
      get :index

      expect(response).to have_http_status(406)
    end
  end
end
