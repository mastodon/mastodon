# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Redirect page for accounts' do
  describe 'GET /redirect/accounts/:id' do
    context 'with a remote account' do
      let(:account) { Fabricate :account, domain: 'host.example' }

      it 'renders a page with link to resource' do
        get redirect_account_path(id: account.id)

        expect(response)
          .to have_http_status(200)
        expect(response.body)
          .to have_link(ActivityPub::TagManager.instance.url_for(account))
      end

      context 'with json format' do
        it 'renders not found' do
          get redirect_account_path(id: account.id, format: :json)

          expect(response)
            .to have_http_status(404)
        end
      end
    end

    context 'with a local account' do
      let(:account) { Fabricate :account, domain: nil }

      it 'renders not found' do
        get redirect_account_path(id: account.id)

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
