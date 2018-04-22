require 'rails_helper'

RSpec.describe Admin::AccountsController, type: :controller do
  render_views

  let(:user) { Fabricate(:user, admin: true) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    around do |example|
      default_per_page = Account.default_per_page
      Account.paginates_per 1
      example.run
      Account.paginates_per default_per_page
    end

    it 'filters with parameters' do
      new = AccountFilter.method(:new)

      expect(AccountFilter).to receive(:new) do |params|
        h = params.to_h

        expect(h[:local]).to eq '1'
        expect(h[:remote]).to eq '1'
        expect(h[:by_domain]).to eq 'domain'
        expect(h[:silenced]).to eq '1'
        expect(h[:recent]).to eq '1'
        expect(h[:suspended]).to eq '1'
        expect(h[:username]).to eq 'username'
        expect(h[:display_name]).to eq 'display name'
        expect(h[:email]).to eq 'local-part@domain'
        expect(h[:ip]).to eq '0.0.0.42'

        new.call({})
      end

      get :index, params: {
        local: '1',
        remote: '1',
        by_domain: 'domain',
        silenced: '1',
        recent: '1',
        suspended: '1',
        username: 'username',
        display_name: 'display name',
        email: 'local-part@domain',
        ip: '0.0.0.42'
      }
    end

    it 'paginates accounts' do
      Fabricate(:account)

      get :index, params: { page: 2 }

      accounts = assigns(:accounts)
      expect(accounts.count).to eq 1
      expect(accounts.klass).to be Account
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    let(:account) { Fabricate(:account, username: 'bob') }

    it 'returns http success' do
      get :show, params: { id: account.id }
      expect(response).to have_http_status(200)
    end
  end
end
