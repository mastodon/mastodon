# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::InstanceStatsController do
  render_views

  let(:domain) { 'example.com' }

  describe 'GET #show' do
    let(:params) { { domain: domain } }

    it 'returns http success' do
      get :show, params: params
      expect(response).to have_http_status(:ok)
    end

    it 'returns delivery_histories its length is more than 0' do
      get :show, params: params
      json = body_as_json
      expect(json[:delivery_histories].size).to be >= 1
    end

    it 'returns delivery_histories with stat params' do
      get :show, params: params
      json = body_as_json
      json[:delivery_histories].each do |hist|
        expect(hist.keys).to match %i(time success_count failure_count)
      end
    end
  end
end
