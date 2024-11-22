# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::RelaysController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns http success and renders view' do
      get :new

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid data' do
      let(:inbox_url) { 'https://example.com/inbox' }

      before do
        stub_request(:post, inbox_url).to_return(status: 200)
      end

      it 'creates a new relay and redirects' do
        expect do
          post :create, params: { relay: { inbox_url: inbox_url } }
        end.to change(Relay, :count).by(1)

        expect(response).to redirect_to(admin_relays_path)
      end
    end

    context 'with invalid data' do
      it 'does not create new a relay and renders new' do
        expect do
          post :create, params: { relay: { inbox_url: 'invalid' } }
        end.to_not change(Relay, :count)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:relay) { Fabricate(:relay) }

    it 'deletes an existing relay' do
      delete :destroy, params: { id: relay.id }

      expect { relay.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to redirect_to(admin_relays_path)
    end
  end

  describe 'POST #enable' do
    let(:relay) { Fabricate(:relay, state: :idle) }

    before do
      stub_request(:post, /example.com/).to_return(status: 200)
    end

    it 'updates a relay from idle to pending' do
      post :enable, params: { id: relay.id }

      expect(relay.reload).to be_pending
      expect(response).to redirect_to(admin_relays_path)
    end
  end

  describe 'POST #disable' do
    let(:relay) { Fabricate(:relay, state: :pending) }

    before do
      stub_request(:post, /example.com/).to_return(status: 200)
    end

    it 'updates a relay from pending to idle' do
      post :disable, params: { id: relay.id }

      expect(relay.reload).to be_idle
      expect(response).to redirect_to(admin_relays_path)
    end
  end
end
