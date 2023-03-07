# frozen_string_literal: true

require 'rails_helper'

describe Settings::Migration::RedirectsController do
  render_views

  let!(:user) { Fabricate(:user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(200)
    end
  end
end
