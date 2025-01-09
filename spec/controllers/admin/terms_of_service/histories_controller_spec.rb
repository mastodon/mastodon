# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TermsOfService::HistoriesController do
  render_views

  let(:user) { Fabricate(:admin_user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show

      expect(response).to have_http_status(:success)
    end
  end
end
