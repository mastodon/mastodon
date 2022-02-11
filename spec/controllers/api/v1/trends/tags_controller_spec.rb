# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Trends::TagsController, type: :controller do
  render_views

  describe 'GET #index' do
    before do
      trending_tags = double()

      allow(trending_tags).to receive(:get).and_return(Fabricate.times(10, :tag))
      allow(Trends).to receive(:tags).and_return(trending_tags)

      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end
end
