# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authorize interactions' do
  describe 'GET /authorize_interaction' do
    context 'when signed out' do
      it 'redirects to sign in page' do
        get authorize_interaction_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end

    context 'when signed in' do
      let(:user) { Fabricate(:user) }

      before { sign_in user }

      it 'returns http not found without acct param' do
        get authorize_interaction_path

        expect(response)
          .to have_http_status(404)
      end

      it 'returns http not found when account cannot be resolved' do
        service = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('missing@hostname').and_return(nil)

        get authorize_interaction_path, params: { acct: 'acct:missing@hostname' }

        expect(response)
          .to have_http_status(404)
        expect(service)
          .to have_received(:call).with('missing@hostname')
      end

      it 'redirects to the account resolved from a URL' do
        account = Fabricate(:account)
        service = instance_double(ResolveURLService)
        allow(ResolveURLService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('http://example.com').and_return(account)

        get authorize_interaction_path, params: { acct: 'http://example.com' }

        expect(response)
          .to have_http_status(302)
          .and redirect_to(web_url("@#{account.pretty_acct}"))
      end

      it 'redirects to the account resolved from an acct URI' do
        account = Fabricate(:account)
        service = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(service)
        allow(service).to receive(:call).with('found@hostname').and_return(account)

        get authorize_interaction_path, params: { acct: 'acct:found@hostname' }

        expect(response)
          .to have_http_status(302)
          .and redirect_to(web_url("@#{account.pretty_acct}"))
      end
    end
  end
end
