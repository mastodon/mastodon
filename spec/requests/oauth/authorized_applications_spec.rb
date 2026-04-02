# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OAuth Authorized Applications' do
  describe 'GET /oauth/authorized_applications' do
    subject { get oauth_authorized_applications_path }

    context 'when signed in' do
      before { sign_in Fabricate(:user) }

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

  describe 'DELETE /oauth/authorized_applications/:id' do
    subject { delete oauth_authorized_application_path(application) }

    let!(:user) { Fabricate(:user) }
    let!(:application) { Fabricate(:application) }
    let!(:access_token) { Fabricate(:accessible_access_token, application: application, resource_owner_id: user.id) }
    let!(:web_push_subscription) { Fabricate(:web_push_subscription, user: user, access_token: access_token) }
    let(:redis_pipeline_stub) { instance_double(Redis::PipelinedConnection, publish: nil) }

    before { allow(redis).to receive(:pipelined).and_yield(redis_pipeline_stub) }

    context 'when signed in' do
      before { sign_in user }

      it 'revokes access tokens for the application and removes subscriptions and sends kill payload to streaming' do
        expect { subject }
          .to change { Doorkeeper::AccessToken.where(application:).first.reload.revoked_at }.from(nil).to(be_present)
          .and change { Web::PushSubscription.where(user:).reload.count }.to(0)
        expect { web_push_subscription.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
        expect(redis_pipeline_stub)
          .to have_received(:publish).with("timeline:access_token:#{access_token.id}", '{"event":"kill"}')
      end
    end
  end
end
