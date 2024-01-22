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

        expect(response).to have_http_status(404)
      end

      it 'renders error when account cant be found' do
        service = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('missing@hostname').and_return(nil)

        get :show, params: { acct: 'acct:missing@hostname' }

        expect(response).to have_http_status(404)
        expect(service).to have_received(:call).with('missing@hostname')
      end

      it 'sets resource from url' do
        account = Fabricate(:account)
        service = instance_double(ResolveURLService)
        allow(ResolveURLService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('http://example.com').and_return(account)

        get :show, params: { acct: 'http://example.com' }

        expect(response).to have_http_status(302)
        expect(assigns(:resource)).to eq account
      end

      it 'sets resource from acct uri' do
        account = Fabricate(:account)
        service = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('found@hostname').and_return(account)

        get :show, params: { acct: 'acct:found@hostname' }

        expect(response).to have_http_status(302)
        expect(assigns(:resource)).to eq account
      end
    end
  end
end
