# frozen_string_literal: true

require 'rails_helper'

describe FiltersController do
  render_views

  describe 'GET #index' do
    context 'with signed out user' do
      before do
        get :index
      end

      it 'redirects' do
        expect(response).to be_redirect
      end
    end

    context 'with a signed in user' do
      before do
        sign_in(Fabricate(:user))
        get :index
      end

      it 'returns http success and private cache control' do
        expect(response)
          .to have_http_status(200)
          .and have_http_header('Cache-Control', 'private, no-store')
      end
    end
  end
end
