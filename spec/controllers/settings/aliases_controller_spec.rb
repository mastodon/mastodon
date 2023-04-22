# frozen_string_literal: true

require 'rails_helper'

describe Settings::AliasesController do
  render_views

  let!(:user) { Fabricate(:user) }
  let(:account) { user.account }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    before do
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns private cache control headers' do
      expect(response.headers['Cache-Control']).to include('private, no-store')
    end
  end

  describe 'POST #create' do
    context 'with valid alias' do
      before { stub_resolver }

      it 'creates an alias for the user' do
        expect do
          post :create, params: { account_alias: { acct: 'new@example.com' } }
        end.to change(AccountAlias, :count).by(1)

        expect(response).to redirect_to(settings_aliases_path)
      end
    end

    context 'with invalid alias' do
      it 'does not create an alias for the user' do
        expect do
          post :create, params: { account_alias: { acct: 'format-wrong' } }
        end.to_not change(AccountAlias, :count)

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:account_alias) do
      AccountAlias.new(account: user.account, acct: 'new@example.com').tap do |account_alias|
        account_alias.save(validate: false)
      end
    end

    it 'removes an alias' do
      delete :destroy, params: { id: account_alias.id }

      expect(response).to redirect_to(settings_aliases_path)
      expect { account_alias.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  private

  def stub_resolver
    resolver = instance_double(ResolveAccountService, call: Fabricate(:account))
    allow(ResolveAccountService).to receive(:new).and_return(resolver)
  end
end
