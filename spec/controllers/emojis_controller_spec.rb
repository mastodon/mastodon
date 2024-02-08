# frozen_string_literal: true

require 'rails_helper'

describe EmojisController do
  render_views

  let(:emoji) { Fabricate(:custom_emoji, shortcode: 'coolcat') }

  describe 'GET #show' do
    let(:response) { get :show, params: { id: emoji.id, format: :json } }

    it 'returns the right response' do
      expect(response).to have_http_status 200
      expect(body_as_json[:name]).to eq ':coolcat:'
    end
  end
end
