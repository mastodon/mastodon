require 'rails_helper'

describe Settings::ApplicationsController do
  render_views
  
  let(:user) { Fabricate(:user) }
  let(:app) { Fabricate(:application, owner: user) }
  
  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    let(:other_app) { Fabricate(:application) }
    before {
      app
      other_app
    }

    it 'shows apps' do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:applications)).to include(app)
      expect(assigns(:applications)).to_not include(other_app)
    end
  end

  
  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: app.id }
      expect(response).to have_http_status(:success)
    end

    it 'returns 404 if you dont own app' do
      app.owner = nil
      app.save

      get :show, params: { id: app.id }
      expect(response.status).to eq 404
    end
  end

  describe 'GET #new' do
    it 'works' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    describe 'success' do
      before do
        post :create, params: {
               doorkeeper_application: {
                 name: 'My New App',
                 redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
                 website: 'http://google.com',
                 scopes: 'read write follow'
               }
             }
      end
      
      it 'redirects back to applications page' do
        expect(response).to redirect_to(settings_applications_path)
      end
    end

    describe 'failure' do
      before do
        post :create, params: {
               doorkeeper_application: {
                 name: '',
                 redirect_uri: '',
                 website: '',
                 scopes: ''
               }
             }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders form again' do
        expect(response).to render_template(:new)
      end
    end
  end
  
  describe 'PUT #update' do
    describe 'success' do
      before do
        patch :update, params: {
                id: app.id,
                doorkeeper_application: {
                  website: 'https://foo.bar/'
                }
              }
      end
      
      it 'redirects back to applications page' do
        expect(response).to redirect_to(settings_applications_path)
      end
    end

    describe 'failure' do
      before do
        patch :update, params: {
                id: app.id,
                doorkeeper_application: {
                  name: '',
                  redirect_uri: '',
                  website: '',
                  scopes: ''
                }
              }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders form again' do
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'destroy' do
    before do
      post :destroy, params: { id: app.id }
    end

    it 'redirects back to applications page' do
      expect(response).to redirect_to(settings_applications_path)
    end

    it 'removes the app' do
      expect(Doorkeeper::Application.find_by(id: app.id)).to be nil
    end
  end

  describe 'regenerate' do
    let(:token) { user.token_for_app(app) }
    before do
      expect(token).to_not be_nil
      put :regenerate, params: { application_id: app.id }
    end

    it 'should create new token' do
      expect( user.token_for_app(app) ).to_not eql(token)
    end
  end
end
