# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Email Subscriptions Accounts' do
  let(:user) { Fabricate(:admin_user) }
  let(:account) { Fabricate :account }

  before { sign_in user }

  context 'when feature is disabled' do
    around do |example|
      original = Rails.application.config.x.email_subscriptions
      Rails.application.config.x.email_subscriptions = false
      example.run
      Rails.application.config.x.email_subscriptions = original
    end

    it 'returns not found' do
      get admin_email_subscriptions_account_path(account.id)

      expect(response)
        .to have_http_status(404)
    end
  end
end
