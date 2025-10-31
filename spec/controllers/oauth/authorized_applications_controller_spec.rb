# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OAuth::AuthorizedApplicationsController do
  render_views

  describe 'GET #index' do
    subject do
      get :index
    end

    context 'when signed in' do
      before do
        sign_in Fabricate(:user), scope: :user
      end

      it 'returns http success with private cache control headers' do
        subject
        expect(response)
          .to have_http_status(200)
        expect(response.headers['Cache-Control'])
          .to include('private, no-store')
        expect(response.parsed_body.at('body.admin'))
          .to be_present
        expect(controller.stored_location_for(:user))
          .to eq '/oauth/authorized_applications'
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        subject

        expect(response)
          .to redirect_to '/auth/sign_in'
        expect(controller.stored_location_for(:user))
          .to eq '/oauth/authorized_applications'
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { Fabricate(:user) }
    let!(:application) { Fabricate(:application) }
    let!(:access_token) { Fabricate(:accessible_access_token, application: application, resource_owner_id: user.id) }
    let!(:web_push_subscription) { Fabricate(:web_push_subscription, user: user, access_token: access_token) }
    let(:redis_pipeline_stub) { instance_double(Redis::PipelinedConnection, publish: nil) }

    before do
      sign_in user, scope: :user
      allow(redis).to receive(:pipelined).and_yield(redis_pipeline_stub)
    end

    it 'revokes access tokens for the application and removes subscriptions and sends kill payload to streaming' do
      post :destroy, params: { id: application.id }

      expect(Doorkeeper::AccessToken.where(application: application).first.revoked_at)
        .to_not be_nil
      expect(Web::PushSubscription.where(user: user).count)
        .to eq(0)
      expect { web_push_subscription.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(redis_pipeline_stub)
        .to have_received(:publish).with("timeline:access_token:#{access_token.id}", '{"event":"kill"}')
    end
  end
end
