# frozen_string_literal: true

require 'rails_helper'

describe Settings::ApplicationsController do
  render_views

  let!(:user) { Fabricate(:user) }
  let!(:app) { Fabricate(:application, owner: user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    before { Fabricate(:application) }

    it 'returns http success with private cache control headers', :aggregate_failures do
      get :index

      expect(response)
        .to have_http_status(200)
        .and render_template(:index)
        .and have_attributes(
          headers: hash_including(
            'Cache-Control' => include('private, no-store')
          )
        )
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: app.id }

      expect(response)
        .to have_http_status(200)

      expect(assigns[:application])
        .to eql(app)
    end

    it 'returns 404 if you dont own app' do
      app.update!(owner: nil)

      get :show, params: { id: app.id }

      expect(response)
        .to have_http_status 404
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new

      expect(response)
        .to have_http_status(200)
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
        expect { subject }
          .to change(Doorkeeper::Application, :count)

        expect(response)
          .to redirect_to(settings_applications_path)
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
        expect(response)
          .to redirect_to(settings_applications_path)
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
        expect(response)
          .to have_http_status(200)
          .and render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    context 'when success' do
      it 'updates existing application' do
        patch :update, params: {
          id: app.id,
          doorkeeper_application: { website: 'https://foo.bar/' },
        }

        expect(app.reload.website)
          .to eql('https://foo.bar/')
        expect(response)
          .to redirect_to(settings_application_path(app))
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
        expect(response)
          .to have_http_status(200)
          .and render_template(:show)
      end
    end
  end

  describe 'destroy' do
    it 'redirects back to applications page and removes the app' do
      post :destroy, params: { id: app.id }

      expect(response)
        .to redirect_to(settings_applications_path)

      expect(Doorkeeper::Application.find_by(id: app.id))
        .to be_nil
    end
  end

  describe 'regenerate' do
    let(:token) { user.token_for_app(app) }

    it 'creates new token' do
      expect(token).to_not be_nil
      post :regenerate, params: { id: app.id }

      expect(user.token_for_app(app))
        .to_not eql(token)
    end
  end
end
