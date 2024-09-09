# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filters::StatusesController do
  render_views

  describe 'GET #index' do
    let(:filter) { Fabricate(:custom_filter) }

    context 'with signed out user' do
      it 'redirects' do
        get :index, params: { filter_id: filter }

        expect(response).to be_redirect
      end
    end

    context 'with a signed in user' do
      context 'with the filter user signed in' do
        before do
          sign_in(filter.account.user)
          get :index, params: { filter_id: filter }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns private cache control headers' do
          expect(response.headers['Cache-Control']).to include('private, no-store')
        end
      end

      context 'with another user signed in' do
        before do
          sign_in(Fabricate(:user))
          get :index, params: { filter_id: filter }
        end

        it 'returns http not found' do
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
