# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts Email Subscriptions API', feature: :email_subscriptions do
  let(:account) { Fabricate(:user).account }

  describe 'POST /api/v1/accounts/:id/email_subscriptions' do
    context 'when the account has the permission' do
      let(:role) { Fabricate(:user_role, permissions: UserRole::FLAGS[:manage_email_subscriptions]) }

      before do
        account.user.update!(role: role)
      end

      context 'when user has enabled the setting' do
        before do
          account.user.settings['email_subscriptions'] = true
          account.user.save!
        end

        it 'returns http success' do
          post "/api/v1/accounts/#{account.id}/email_subscriptions", params: { email: 'test@example.com' }

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      context 'when user has not enabled the setting' do
        it 'returns http not found' do
          post "/api/v1/accounts/#{account.id}/email_subscriptions", params: { email: 'test@example.com' }

          expect(response).to have_http_status(404)
        end
      end
    end

    context 'when the account does not have the permission' do
      it 'returns http not found' do
        post "/api/v1/accounts/#{account.id}/email_subscriptions", params: { email: 'test@example.com' }

        expect(response).to have_http_status(404)
      end
    end
  end
end
