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
        expect(response.headers).to_not include('Link')
      end
    end

    context 'when trends are enabled' do
      before { Setting.trends = true }

      it 'returns http success' do
        prepare_trends
        stub_const('Api::V1::Trends::TagsController::DEFAULT_TAGS_LIMIT', 2)
        get :index

        expect(response).to have_http_status(200)
        expect(response.headers).to include('Link')
      end

      def prepare_trends
        Fabricate.times(3, :tag, trendable: true).each do |tag|
          2.times { |i| Trends.tags.add(tag, i) }
        end
        Trends::Tags.new(threshold: 1).refresh
      end
    end
  end
end
