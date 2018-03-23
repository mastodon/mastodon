# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CustomEmojisController, type: :controller do
  render_views

  describe 'GET #index' do
    before do
      Fabricate(:custom_emoji)
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
