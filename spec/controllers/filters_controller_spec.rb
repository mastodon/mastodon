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

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns private cache control headers' do
        expect(response.headers['Cache-Control']).to include('private, no-store')
      end
    end
  end
end
