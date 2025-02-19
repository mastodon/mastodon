# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TermsOfService::PreviewsController do
  render_views

  let(:user) { Fabricate(:admin_user) }
  let(:terms_of_service) { Fabricate(:terms_of_service, notification_sent_at: nil) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { terms_of_service_id: terms_of_service.id }

      expect(response).to have_http_status(:success)
    end
  end
end
