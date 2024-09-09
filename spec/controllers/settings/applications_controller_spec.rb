# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::ApplicationsController do
  render_views

  let!(:user) { Fabricate(:user) }
  let!(:app) { Fabricate(:application, owner: user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    before do
      Fabricate(:application)
      get :index
    end

    it 'returns http success with private cache control headers', :aggregate_failures do
      expect(response).to have_http_status(200)
      expect(response.headers['Cache-Control']).to include('private, no-store')
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: app.id }
      expect(response).to have_http_status(200)
      expect(assigns[:application]).to eql(app)
    end

    it 'returns 404 if you dont own app' do
      app.update!(owner: nil)

      get :show, params: { id: app.id }
      expect(response).to have_http_status 404
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    context 'when success (passed scopes as a String)' do
      subject do
        post :create, params: {
          doorkeeper_application: {
            name: 'My New App',
            redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
            website: 'http://google.com',
            scopes: 'read write follow',
          },
        }
      end

      it 'creates an entry in the database', :aggregate_failures do
        expect { subject }.to change(Doorkeeper::Application, :count)
        expect(response).to redirect_to(settings_applications_path)
      end
    end

    context 'when success (passed scopes as an Array)' do
      subject do
        post :create, params: {
          doorkeeper_application: {
            name: 'My New App',
            redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
            website: 'http://google.com',
            scopes: %w(read write follow),
          },
        }
      end

      it 'creates an entry in the database', :aggregate_failures do
        expect { subject }.to change(Doorkeeper::Application, :count)
        expect(response).to redirect_to(settings_applications_path)
      end
    end

    context 'with failure request' do
      before do
        post :create, params: {
          doorkeeper_application: {
            name: '',
            redirect_uri: '',
            website: '',
            scopes: [],
          },
        }
      end

      it 'returns http success and renders form', :aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    context 'when success' do
      subject do
        patch :update, params: {
          id: app.id,
          doorkeeper_application: opts,
        }
        response
      end

      let(:opts) do
        {
          website: 'https://foo.bar/',
        }
      end

      it 'updates existing application' do
        subject

        expect(app.reload.website).to eql(opts[:website])
        expect(response).to redirect_to(settings_application_path(app))
      end
    end

    context 'with failure request' do
      before do
        patch :update, params: {
          id: app.id,
          doorkeeper_application: {
            name: '',
            redirect_uri: '',
            website: '',
            scopes: [],
          },
        }
      end

      it 'returns http success and renders form', :aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response).to render_template(:show)
      end
    end
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
