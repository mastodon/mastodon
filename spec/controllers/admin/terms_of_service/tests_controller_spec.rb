# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TermsOfService::TestsController do
  render_views

  let(:user) { Fabricate(:admin_user) }
  let(:terms_of_service) { Fabricate(:terms_of_service, notification_sent_at: nil) }

  before do
    sign_in user, scope: :user
  end

  describe 'POST #create' do
    it 'returns http success' do
      post :create, params: { terms_of_service_id: terms_of_service.id }

      expect(response).to redirect_to(admin_terms_of_service_preview_path(terms_of_service))
    end
  end
end
