# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Exports / Muted Accounts' do
  describe 'GET /settings/exports/mutes' do
    context 'with a signed in user who has muted accounts' do
      let(:user) { Fabricate :user }

      before do
        Fabricate(
          :mute,
          account: user.account,
          target_account: Fabricate(:account, username: 'username', domain: 'domain')
        )
        sign_in user
      end

      it 'returns a CSV with the muted accounts' do
        get '/settings/exports/mutes.csv'

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to eq('text/csv')
        expect(response.body)
          .to eq(<<~CSV)
            Account address,Hide notifications
            username@domain,true
          CSV
      end
    end

    describe 'when signed out' do
      it 'returns unauthorized' do
        get '/settings/exports/mutes.csv'

        expect(response)
          .to have_http_status(401)
      end
    end
  end
end
