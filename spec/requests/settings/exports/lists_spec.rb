# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Exports / Lists' do
  describe 'GET /settings/exports/lists' do
    context 'with a signed in user who has lists' do
      let(:account) { Fabricate(:account, username: 'test', domain: 'example.com') }
      let(:list) { Fabricate :list, account: account, title: 'The List' }
      let(:user) { Fabricate(:user, account: account) }

      before do
        Fabricate(:list_account, list: list, account: account)
        sign_in user
      end

      it 'returns a CSV with the list' do
        get '/settings/exports/lists.csv'

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to eq('text/csv')
        expect(response.body)
          .to eq(<<~CSV)
            The List,test@example.com
          CSV
      end
    end

    describe 'when signed out' do
      it 'returns unauthorized' do
        get '/settings/exports/lists.csv'

        expect(response)
          .to have_http_status(401)
      end
    end
  end
end
