require 'rails_helper'

RSpec.describe Admin::AccountsController, type: :controller do
  render_views

  let(:user) { Fabricate(:user, admin: true) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    it 'filters with local parameter' do
      to_select = Fabricate(:account, domain: nil)
      to_reject = Fabricate(:account, domain: Faker::Internet.domain_name)

      get :index, params: { local: true }

      accounts = assigns(:accounts)
      expect(accounts).to include to_select
      expect(accounts).not_to include to_reject
    end

    it 'filters with remote parameter' do
      to_select = Fabricate(:account, domain: Faker::Internet.domain_name)
      to_reject = Fabricate(:account, domain: nil)

      get :index, params: { remote: false }

      accounts = assigns(:accounts)
      expect(accounts).to include to_select
      expect(accounts).not_to include to_reject
    end

    it 'filters with by_domain parameter' do
      to_select = Fabricate(:account, domain: 'domain')
      to_reject = Fabricate(:account, domain: nil)

      get :index, params: { by_domain: 'domain' }

      accounts = assigns(:accounts)
      expect(accounts).to include to_select
      expect(accounts).not_to include to_reject
    end

    it 'filters with silenced parameter' do
      to_select = Fabricate(:account, silenced: true)
      to_reject = Fabricate(:account, silenced: false)

      get :index, params: { silenced: true }

      accounts = assigns(:accounts)
      expect(accounts).to include to_select
      expect(accounts).not_to include to_reject
    end

    it 'filters with recent parameter' do
      to_select = 2.times.map { Fabricate(:account) }

      get :index, params: { recent: true }

      accounts = assigns(:accounts)
      expect(accounts[0]).to eq to_select[1]
      expect(accounts[1]).to eq to_select[0]
    end

    it 'filters with suspended parameter' do
      to_select = Fabricate(:account, suspended: true)
      to_reject = Fabricate(:account, suspended: false)

      get :index, params: { suspended: true }

      accounts = assigns(:accounts)
      expect(accounts).to include to_select
      expect(accounts).not_to include to_reject
    end

    it 'filters with username parameter' do
      to_select = Fabricate(:account, username: 'specified')
      to_reject = Fabricate(:account, username: 'different')

      get :index, params: { username: 'specified' }

      accounts = assigns(:accounts)
      expect(accounts).to include to_select
      expect(accounts).not_to include to_reject
    end

    it 'filters with display_name parameter' do
      to_select = Fabricate(:account, display_name: 'specified')
      to_reject = Fabricate(:account, display_name: 'different')

      get :index, params: { display_name: 'specified' }

      accounts = assigns(:accounts)
      expect(accounts).to include to_select
      expect(accounts).not_to include to_reject
    end

    it 'filters with email parameter' do
      to_select = Fabricate(:user, email: 'specified@email.net')
      to_reject = Fabricate(:user, email: 'different@email.net')

      get :index, params: { email: 'specified@email.net' }

      accounts = assigns(:accounts)
      expect(accounts).to include to_select.account
      expect(accounts).not_to include to_reject.account
    end

    it 'filters with ip parameter' do
      to_select = Fabricate(:user, current_sign_in_ip: '0.0.0.42')
      to_reject = Fabricate(:user, current_sign_in_ip: '0.0.0.41')

      get :index, params: { ip: '0.0.0.42' }

      accounts = assigns(:accounts)
      expect(accounts).to include to_select.account
      expect(accounts).not_to include to_reject.account
    end

    it 'paginates accounts' do
      Fabricate(:account)

      default_per_page = Account.default_per_page
      Account.paginates_per 1
      begin
        get :index, params: { page: 2 }
      ensure
        Account.paginates_per default_per_page
      end

      accounts = assigns(:accounts)
      expect(accounts.count).to eq 1
      expect(accounts.klass).to be Account
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'does not filter with IP address if the IP address is invalid' do
      get :index, params: { ip: 'invalid' }
      expect(assigns(:accounts)).to eq [user.account]
    end

    it 'filters with IP address if the IP address is valid' do
      match = Fabricate(:user, current_sign_in_ip: nil, last_sign_in_ip: '127.0.0.1')
      get :index, params: { ip: '127.0.0.1' }
      expect(assigns(:accounts)).to eq [match.account]
    end
  end

  describe 'GET #show' do
    let(:account) { Fabricate(:account, username: 'bob') }

    it 'returns http success' do
      get :show, params: { id: account.id }
      expect(response).to have_http_status(:success)
    end
  end
end
