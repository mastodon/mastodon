# frozen_string_literal: true

require 'rails_helper'

describe Admin::RulesController do
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
    let(:rule) { Fabricate(:rule) }

    it 'returns http success and renders edit' do
      get :edit, params: { id: rule.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'with valid data' do
      it 'creates a new rule and redirects' do
        expect do
          post :create, params: { rule: { text: 'The rule text.' } }
        end.to change(Rule, :count).by(1)

        expect(response).to redirect_to(admin_rules_path)
      end
    end

    context 'with invalid data' do
      it 'does creates a new rule and renders index' do
        expect do
          post :create, params: { rule: { text: '' } }
        end.to_not change(Rule, :count)

        expect(response).to render_template(:index)
      end
    end
  end

  describe 'PUT #update' do
    let(:rule) { Fabricate(:rule, text: 'Original text') }

    context 'with valid data' do
      it 'updates the rule and redirects' do
        put :update, params: { id: rule.id, rule: { text: 'Updated text.' } }

        expect(response).to redirect_to(admin_rules_path)
      end
    end

    context 'with invalid data' do
      it 'does not update the rule and renders index' do
        put :update, params: { id: rule.id, rule: { text: '' } }

        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:rule) { Fabricate(:rule) }

    it 'destroys the rule and redirects' do
      delete :destroy, params: { id: rule.id }

      expect(rule.reload).to be_discarded
      expect(response).to redirect_to(admin_rules_path)
    end
  end
end
