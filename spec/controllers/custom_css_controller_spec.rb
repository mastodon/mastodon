# frozen_string_literal: true

require 'rails_helper'

describe CustomCssController do
  render_views

  describe 'GET #show' do
    before do
      get :show
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns public cache control header' do
      expect(response.headers['Cache-Control']).to include('public')
    end

    it 'does not set cookies' do
      expect(response.cookies).to be_empty
      expect(response.headers['Set-Cookies']).to be_nil
    end

    it 'does not set sessions' do
      expect(session).to be_empty
    end
  end
end
