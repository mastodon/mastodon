# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'The catch all route' do
  describe 'with a simple value' do
    it 'returns a 404 page as html' do
      get '/test'

      expect(response).to have_http_status 404
      expect(response.media_type).to eq 'text/html'
    end
  end

  describe 'with an implied format' do
    it 'returns a 404 page as html' do
      get '/test.test'

      expect(response).to have_http_status 404
      expect(response.media_type).to eq 'text/html'
    end
  end
end
