# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Statuses' do
  describe 'GET /@:account_username/:id' do
    let(:account) { Fabricate(:account) }
    let(:status)  { Fabricate(:status, account: account) }

    context 'when signed out' do
      context 'when account is permanently suspended' do
        before do
          account.suspend!
          account.deletion_request.destroy
        end

        it 'returns http gone' do
          get "/@#{account.username}/#{status.id}"

          expect(response)
            .to have_http_status(410)
        end
      end

      context 'when account is temporarily suspended' do
        before { account.suspend! }

        it 'returns http forbidden' do
          get "/@#{account.username}/#{status.id}"

          expect(response)
            .to have_http_status(403)
        end
      end

      context 'when status is a reblog' do
        let(:original_account) { Fabricate(:account, domain: 'example.com') }
        let(:original_status) { Fabricate(:status, account: original_account, url: 'https://example.com/123') }
        let(:status) { Fabricate(:status, account: account, reblog: original_status) }

        it 'redirects to the original status' do
          get "/@#{status.account.username}/#{status.id}"

          expect(response)
            .to redirect_to(original_status.url)
        end
      end
    end

    context 'when signed in' do
      let(:user) { Fabricate(:user) }

      before { sign_in(user) }

      context 'when account blocks user' do
        before { account.block!(user.account) }

        it 'returns http not found' do
          get "/@#{status.account.username}/#{status.id}"

          expect(response)
            .to have_http_status(404)
        end
      end
    end
  end
end
