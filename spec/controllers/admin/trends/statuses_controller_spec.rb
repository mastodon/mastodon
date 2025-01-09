# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Trends::StatusesController do
  render_views

  let(:user) { Fabricate(:admin_user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end
end
