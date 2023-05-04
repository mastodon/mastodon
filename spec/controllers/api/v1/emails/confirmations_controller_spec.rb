# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Emails::ConfirmationsController do
  let(:confirmed_at) { nil }
  let(:user)         { Fabricate(:user, confirmed_at: confirmed_at) }
  let(:app)          { Fabricate(:application) }
  let(:token)        { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes, application: app) }
  let(:scopes)       { 'write' }

  describe '#create' do
    context 'with an oauth token' do
      before do
        allow(controller).to receive(:doorkeeper_token) { token }
      end

      context 'when from a random app' do
        it 'returns http forbidden' do
          post :create
          expect(response).to have_http_status(403)
        end
      end

      context 'when from an app that created the account' do
        before do
          user.update(created_by_application: token.application)
        end

        context 'when the account is already confirmed' do
          let(:confirmed_at) { Time.now.utc }

          it 'returns http forbidden' do
            post :create
            expect(response).to have_http_status(403)
          end

          context 'with user changed e-mail and has not confirmed it' do
            before do
              user.update(email: 'foo@bar.com')
            end

            it 'returns http success' do
              post :create
              expect(response).to have_http_status(:success)
            end
          end
        end

        context 'when the account is unconfirmed' do
          it 'returns http success' do
            post :create
            expect(response).to have_http_status(:success)
          end
        end
      end
    end

    context 'without an oauth token' do
      it 'returns http unauthorized' do
        post :create
        expect(response).to have_http_status(401)
      end
    end
  end
end
