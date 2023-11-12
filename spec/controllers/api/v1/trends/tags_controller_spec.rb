# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Trends::TagsController do
  render_views

  describe 'GET #index' do
    around do |example|
      previous = Setting.trends
      example.run
      Setting.trends = previous
    end

    context 'when trends are disabled' do
      before { Setting.trends = false }

      it 'returns http success' do
        get :index

        expect(response).to have_http_status(200)
      end
    end

    context 'when trends are enabled' do
      before do
        Setting.trends = true
        Fabricate.times(10, :tag).each do |tag|
          10.times { |i| Trends.tags.add(tag, i) }
        end
      end

      it 'returns http success' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end
end
