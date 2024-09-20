# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::ApplicationsController do
  render_views

  let!(:user) { Fabricate(:user) }
  let!(:app) { Fabricate(:application, owner: user) }

  before do
    sign_in user, scope: :user
  end

  describe 'destroy' do
    let(:redis_pipeline_stub) { instance_double(Redis::Namespace, publish: nil) }
    let!(:access_token) { Fabricate(:accessible_access_token, application: app) }

    before do
      allow(redis).to receive(:pipelined).and_yield(redis_pipeline_stub)
      post :destroy, params: { id: app.id }
    end

    it 'redirects back to applications page removes the app' do
      expect(response).to redirect_to(settings_applications_path)
      expect(Doorkeeper::Application.find_by(id: app.id)).to be_nil
    end

    it 'sends a session kill payload to the streaming server' do
      expect(redis_pipeline_stub).to have_received(:publish).with("timeline:access_token:#{access_token.id}", '{"event":"kill"}')
    end
  end

  describe 'regenerate' do
    let(:token) { user.token_for_app(app) }

    it 'creates new token' do
      expect(token).to_not be_nil
      post :regenerate, params: { id: app.id }

      expect(user.token_for_app(app)).to_not eql(token)
    end
  end
end
