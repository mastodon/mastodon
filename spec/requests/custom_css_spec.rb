# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom CSS' do
  include RoutingHelper

  describe 'GET /custom.css' do
    context 'without any CSS or User Roles' do
      it 'returns empty stylesheet' do
        get '/custom.css'

        expect(response.content_type).to include('text/css')
        expect(response.body.presence).to be_nil
      end
    end

    context 'with CSS settings' do
      before do
        Setting.custom_css = expected_css
      end

      it 'returns stylesheet from settings' do
        get '/custom.css'

        expect(response.content_type).to include('text/css')
        expect(response.body.strip).to eq(expected_css)
      end

      def expected_css
        <<~CSS.strip
          body { background-color: red; }
        CSS
      end
    end

    context 'with highlighted colored UserRole records' do
      before do
        _highlighted_colored = Fabricate :user_role, highlighted: true, color: '#336699', id: '123_123_123'
        _highlighted_no_color = Fabricate :user_role, highlighted: true, color: ''
        _no_highlight_with_color = Fabricate :user_role, highlighted: false, color: ''
      end

      it 'returns stylesheet from settings' do
        get '/custom.css'

        expect(response.content_type).to include('text/css')
        expect(response.body.strip).to eq(expected_css)
      end

      def expected_css
        <<~CSS.strip
          .user-role-123123123 {
            --user-role-accent: #336699;
          }
        CSS
      end
    end
  end
end
