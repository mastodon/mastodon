# frozen_string_literal: true

require 'rails_helper'

describe Oauth::AuthorizedApplicationsController do
  render_views

  before do
    sign_in Fabricate(:user), scope: :user
  end

  describe 'GET #index' do
    before do
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
