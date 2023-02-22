# frozen_string_literal: true

require 'rails_helper'

describe ManifestsController do
  render_views

  describe 'GET #show' do
    before do
      get :show, format: :json
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end
end
