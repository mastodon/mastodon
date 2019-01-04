# frozen_string_literal: true

require 'rails_helper'

describe AuthorizeFollowsController do
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
      let(:account) { Fabricate(:account, user: user) }

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

      it 'sets account from url' do
        account = Account.new
        service = double
        allow(FetchRemoteAccountService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('http://example.com').and_return(account)

        get :show, params: { acct: 'http://example.com' }

        expect(response).to have_http_status(:success)
        expect(assigns(:account)).to eq account
      end

      it 'sets account from acct uri' do
        account = Account.new
        service = double
        allow(ResolveAccountService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('found@hostname').and_return(account)

        get :show, params: { acct: 'acct:found@hostname' }

        expect(response).to have_http_status(:success)
        expect(assigns(:account)).to eq account
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
      let(:user) { Fabricate(:user) }
      let(:account) { Fabricate(:account, user: user) }

      before do
        sign_in(user)
      end

      it 'shows error when account not found' do
        service = double
        allow(FollowService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with(account, 'user@hostname').and_return(nil)

        post :create, params: { acct: 'acct:user@hostname' }

        expect(service).to have_received(:call).with(account, 'user@hostname')
        expect(response).to render_template(:error)
      end

      it 'follows account when found' do
        target_account = Fabricate(:account)
        result_account = double(target_account: target_account)
        service = double
        allow(FollowService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with(account, 'user@hostname').and_return(result_account)

        post :create, params: { acct: 'acct:user@hostname' }

        expect(service).to have_received(:call).with(account, 'user@hostname')
        expect(response).to render_template(:success)
      end
    end
  end
end
