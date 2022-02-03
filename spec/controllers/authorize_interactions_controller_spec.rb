# frozen_string_literal: true

require 'rails_helper'

describe AuthorizeInteractionsController do
  render_views

  describe 'GET #show' do
    describe 'when signed out' do
      it 'redirects to sign in page' do
        get :show

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'when signed in' do
      let(:user) { Fabricate(:user) }

      before do
        sign_in(user)
      end

      it 'renders error without acct param' do
        get :show

        expect(response).to render_template(:error)
      end

      it 'renders error when account cant be found' do
        service = double
        allow(ResolveAccountService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('missing@hostname').and_return(nil)

        get :show, params: { acct: 'acct:missing@hostname' }

        expect(response).to render_template(:error)
        expect(service).to have_received(:call).with('missing@hostname')
      end

      it 'sets resource from url' do
        account = Account.new
        service = double
        allow(ResolveURLService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('http://example.com').and_return(account)

        get :show, params: { acct: 'http://example.com' }

        expect(response).to have_http_status(200)
        expect(assigns(:resource)).to eq account
      end

      it 'sets resource from acct uri' do
        account = Account.new
        service = double
        allow(ResolveAccountService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('found@hostname').and_return(account)

        get :show, params: { acct: 'acct:found@hostname' }

        expect(response).to have_http_status(200)
        expect(assigns(:resource)).to eq account
      end
    end
  end

  describe 'POST #create' do
    describe 'when signed out' do
      it 'redirects to sign in page' do
        post :create

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'when signed in' do
      let!(:user) { Fabricate(:user) }
      let(:account) { user.account }

      before do
        sign_in(user)
      end

      it 'shows error when account not found' do
        service = double

        allow(ResolveAccountService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('user@hostname').and_return(nil)

        post :create, params: { acct: 'acct:user@hostname' }

        expect(response).to render_template(:error)
      end

      it 'follows account when found' do
        target_account = Fabricate(:account)
        service = double

        allow(ResolveAccountService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('user@hostname').and_return(target_account)


        post :create, params: { acct: 'acct:user@hostname' }

        expect(account.following?(target_account)).to be true
        expect(response).to render_template(:success)
      end
    end
  end
end
