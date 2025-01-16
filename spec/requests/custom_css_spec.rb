# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom CSS' do
  include RoutingHelper

  describe 'GET /css/:id.css' do
    context 'without any CSS or User Roles' do
      it 'returns empty stylesheet' do
        get '/css/custom-123.css'

        expect(response)
          .to have_http_status(200)
          .and have_cacheable_headers
          .and have_attributes(
            content_type: match('text/css')
          )
        expect(response.body.presence)
          .to be_nil
      end
    end

    context 'with CSS settings' do
      before do
        Setting.custom_css = expected_css
      end

      it 'returns stylesheet from settings' do
        get '/css/custom-456.css'

        expect(response)
          .to have_http_status(200)
          .and have_cacheable_headers
          .and have_attributes(
            content_type: match('text/css')
          )
        expect(response.body.strip)
          .to eq(expected_css)
      end

      def expected_css
        <<~CSS.strip
          body { background-color: red; }
        CSS
      end
    end
  end
end
