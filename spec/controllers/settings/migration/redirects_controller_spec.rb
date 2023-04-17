# frozen_string_literal: true

require 'rails_helper'

describe Settings::Migration::RedirectsController do
  render_views

  let!(:user) { Fabricate(:user, password: 'testtest') }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      before { stub_resolver }

      it 'redirects to the settings migration path' do
        post :create, params: { form_redirect: { acct: 'new@host.com', current_password: 'testtest' } }

        expect(response).to redirect_to(settings_migration_path)
      end
    end

    context 'with non valid params' do
      it 'returns success and renders the new page' do
        post :create, params: { form_redirect: { acct: '' } }

        expect(response).to have_http_status(200)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:account) { Fabricate(:account) }

    before do
      user.account.update(moved_to_account_id: account.id)
    end

    it 'resets the account and sends an update' do
      delete :destroy

      expect(response).to redirect_to(settings_migration_path)
      expect(user.account.reload.moved_to_account).to be_nil
    end
  end

  private

  def stub_resolver
    resolver = instance_double(ResolveAccountService, call: Fabricate(:account))
    allow(ResolveAccountService).to receive(:new).and_return(resolver)
  end
end
