# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Exports / Bookmarks' do
  describe 'GET /settings/exports/bookmarks' do
    context 'with a signed in user who has bookmarks' do
      let(:account) { Fabricate(:account, domain: 'foo.bar') }
      let(:status) { Fabricate(:status, account: account, uri: 'https://foo.bar/statuses/1312') }
      let(:user) { Fabricate(:user) }

      before do
        Fabricate(
          :bookmark,
          account: user.account,
          status: status
        )
        sign_in user
      end

      it 'returns a CSV with the bookmarked statuses' do
        get '/settings/exports/bookmarks.csv'

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to eq('text/csv')
        expect(response.body)
          .to eq(<<~CSV)
            https://foo.bar/statuses/1312
          CSV
      end
    end

    describe 'when signed out' do
      it 'returns unauthorized' do
        get '/settings/exports/bookmarks.csv'

        expect(response)
          .to have_http_status(401)
      end
    end
  end
end
