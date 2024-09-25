# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::WarningPresetsController do
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

  describe 'GET #edit' do
    let(:account_warning_preset) { Fabricate(:account_warning_preset) }

    it 'returns http success and renders edit' do
      get :edit, params: { id: account_warning_preset.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'with valid data' do
      it 'creates a new account_warning_preset and redirects' do
        expect do
          post :create, params: { account_warning_preset: { text: 'The account_warning_preset text.' } }
        end.to change(AccountWarningPreset, :count).by(1)

        expect(response).to redirect_to(admin_warning_presets_path)
      end
    end

    context 'with invalid data' do
      it 'does creates a new account_warning_preset and renders index' do
        expect do
          post :create, params: { account_warning_preset: { text: '' } }
        end.to_not change(AccountWarningPreset, :count)

        expect(response).to render_template(:index)
      end
    end
  end

  describe 'PUT #update' do
    let(:account_warning_preset) { Fabricate(:account_warning_preset, text: 'Original text') }

    context 'with valid data' do
      it 'updates the account_warning_preset and redirects' do
        put :update, params: { id: account_warning_preset.id, account_warning_preset: { text: 'Updated text.' } }

        expect(response).to redirect_to(admin_warning_presets_path)
      end
    end

    context 'with invalid data' do
      it 'does not update the account_warning_preset and renders index' do
        put :update, params: { id: account_warning_preset.id, account_warning_preset: { text: '' } }

        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:account_warning_preset) { Fabricate(:account_warning_preset) }

    it 'destroys the account_warning_preset and redirects' do
      delete :destroy, params: { id: account_warning_preset.id }

      expect { account_warning_preset.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to redirect_to(admin_warning_presets_path)
    end
  end
end
