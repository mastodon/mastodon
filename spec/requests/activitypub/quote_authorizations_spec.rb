# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActivityPub QuoteAuthorization endpoint' do
  let(:account) { Fabricate(:account, domain: nil) }
  let(:status) { Fabricate :status, account: account }
  let(:quote) { Fabricate(:quote, quoted_status: status, state: :accepted) }

  before { Fabricate :favourite, status: status }

  describe 'GET /accounts/:account_username/quote_authorizations/:quote_id' do
    context 'with an accepted quote' do
      it 'returns http success and activity json' do
        get account_quote_authorization_url(quote.quoted_account, quote)

        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq 'application/activity+json'

        expect(response.parsed_body)
          .to include(type: 'QuoteAuthorization')
      end
    end

    context 'with an incorrect quote authorization URL' do
      it 'returns http not found' do
        get account_quote_authorization_url(quote.account, quote)

        expect(response)
          .to have_http_status(404)
      end
    end

    context 'with a rejected quote' do
      before do
        quote.reject!
      end

      it 'returns http not found' do
        get account_quote_authorization_url(quote.quoted_account, quote)

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
