# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Webhooks::SecretsController do
  render_views

  let(:user) { Fabricate(:admin_user) }

  before do
    sign_in user, scope: :user
  end

  describe 'POST #rotate' do
    let(:webhook) { Fabricate(:webhook) }

    it 'returns http success' do
      post :rotate, params: { webhook_id: webhook.id }

      expect(response).to redirect_to(admin_webhook_path(webhook))
    end
  end
end
