# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Trends::TagsController do
  render_views

  describe 'GET #index' do
    before do
      Fabricate.times(10, :tag).each do |tag|
        10.times { |i| Trends.tags.add(tag, i) }
      end

      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end
end
