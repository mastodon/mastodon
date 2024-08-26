# frozen_string_literal: true

require 'rails_helper'

describe 'Settings / Exports / Blocked Accounts' do
  describe 'GET /settings/exports/blocks' do
    context 'with a signed in user who has blocked accounts' do
      let(:user) { Fabricate :user }

      before do
        user.account.block!(Fabricate(:account, username: 'username', domain: 'domain'))
        sign_in user
      end

      it 'returns a CSV with the blocking accounts' do
        get '/settings/exports/blocks.csv'

        expect(response)
          .to have_http_status(200)
        expect(response.body)
          .to eq(<<~CSV)
            username@domain
          CSV
      end
    end
  end
end
