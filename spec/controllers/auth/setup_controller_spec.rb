# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::SetupController do
  render_views

  describe 'GET #show' do
    context 'with a signed out request' do
      it 'returns http redirect' do
        get :show
        expect(response).to be_redirect
      end
    end

    context 'with an unconfirmed signed in user' do
      before { sign_in Fabricate(:user, confirmed_at: nil) }

      it 'returns http success' do
        get :show
        expect(response).to have_http_status(200)
      end
    end
  end
end
