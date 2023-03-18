# frozen_string_literal: true

require 'rails_helper'

describe Filters::StatusesController do
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
        before { sign_in(filter.account.user) }

        it 'returns http success' do
          get :index, params: { filter_id: filter }

          expect(response).to have_http_status(200)
        end
      end

      context 'with another user signed in' do
        before { sign_in(Fabricate(:user)) }

        it 'returns http not found' do
          get :index, params: { filter_id: filter }

          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
