# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Exports / Blocked Accounts' do
  describe 'GET /settings/exports/blocks' do
    context 'with a signed in user who has blocked accounts' do
      let(:user) { Fabricate :user }

      before do
        Fabricate(
          :block,
          account: user.account,
          target_account: Fabricate(:account, username: 'username', domain: 'domain')
        )
        sign_in user
      end

      it 'returns a CSV with the blocking accounts' do
        get '/settings/exports/blocks.csv'

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to eq('text/csv')
        expect(response.body)
          .to eq(<<~CSV)
            username@domain
          CSV
      end
    end

    describe 'when signed out' do
      it 'returns unauthorized' do
        get '/settings/exports/blocks.csv'

        expect(response)
          .to have_http_status(401)
      end
    end
  end
end
