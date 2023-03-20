# frozen_string_literal: true

require 'rails_helper'

describe FiltersController do
  render_views

  describe 'GET #index' do
    context 'with signed out user' do
      it 'redirects' do
        get :index

        expect(response).to be_redirect
      end
    end

    context 'with a signed in user' do
      before { sign_in(Fabricate(:user)) }

      it 'returns http success' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end
end
