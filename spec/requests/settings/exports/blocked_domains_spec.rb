# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Exports / Blocked Domains' do
  describe 'GET /settings/exports/domain_blocks' do
    context 'with a signed in user who has blocked domains' do
      let(:account) { Fabricate :account, domain: 'example.com' }
      let(:user) { Fabricate :user, account: account }

      before do
        Fabricate(:account_domain_block, domain: 'example.com', account: account)
        sign_in user
      end

      it 'returns a CSV with the domains' do
        get '/settings/exports/domain_blocks.csv'

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to eq('text/csv')
        expect(response.body)
          .to eq(<<~CSV)
            example.com
          CSV
      end
    end

    describe 'when signed out' do
      it 'returns unauthorized' do
        get '/settings/exports/domain_blocks.csv'

        expect(response)
          .to have_http_status(401)
      end
    end
  end
end
