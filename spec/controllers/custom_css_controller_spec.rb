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

    it_behaves_like 'cacheable response'
  end
end
