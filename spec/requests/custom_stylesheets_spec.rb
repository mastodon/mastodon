# frozen_string_literal: true

require 'rails_helper'

describe 'Custom stylesheets' do
  describe 'GET /custom.css' do
    before { get '/custom.css' }

    it 'returns http success' do
      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          content_type: match('text/css')
        )
    end

    it_behaves_like 'cacheable response'
  end
end
