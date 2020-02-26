# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TrendsController, type: :controller do
  render_views

  describe 'GET #index' do
    before do
      allow(TrendingTags).to receive(:get).and_return(Fabricate.times(10, :tag))
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end
end
