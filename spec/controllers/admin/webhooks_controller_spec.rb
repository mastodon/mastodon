# frozen_string_literal: true

require 'rails_helper'

describe Admin::WebhooksController do
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
    it 'creates a new webhook record with valid data' do
      expect do
        post :create, params: { webhook: { url: 'https://example.com/hook', events: ['account.approved'] } }
      end.to change(Webhook, :count).by(1)

      expect(response).to be_redirect
    end

    it 'does not create a new webhook record with invalid data' do
      expect do
        post :create, params: { webhook: { url: 'https://example.com/hook', events: [] } }
      end.to_not change(Webhook, :count)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  context 'with an existing record' do
    let!(:webhook) { Fabricate(:webhook, events: ['account.created', 'report.created']) }

    describe 'GET #show' do
      it 'returns http success and renders view' do
        get :show, params: { id: webhook.id }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

    describe 'GET #edit' do
      it 'returns http success and renders view' do
        get :edit, params: { id: webhook.id }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT #update' do
      it 'updates the record with valid data' do
        put :update, params: { id: webhook.id, webhook: { url: 'https://example.com/new/location' } }

        expect(webhook.reload.url).to match(%r{new/location})
        expect(response).to redirect_to(admin_webhook_path(webhook))
      end

      it 'does not update the record with invalid data' do
        expect do
          put :update, params: { id: webhook.id, webhook: { url: '' } }
        end.to_not change(webhook, :url)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the record' do
        expect do
          delete :destroy, params: { id: webhook.id }
        end.to change(Webhook, :count).by(-1)

        expect(response).to redirect_to(admin_webhooks_path)
      end
    end
  end
end
