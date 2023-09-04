# frozen_string_literal: true

require 'rails_helper'

describe Settings::Exports::BookmarksController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:account) { Fabricate(:account, domain: 'foo.bar') }
  let(:status)  { Fabricate(:status, account: account, uri: 'https://foo.bar/statuses/1312') }

  describe 'GET #index' do
    before do
      user.account.bookmarks.create!(status: status)
    end

    it 'returns a csv of the bookmarked toots' do
      sign_in user, scope: :user
      get :index, format: :csv

      expect(response.body).to eq "https://foo.bar/statuses/1312\n"
    end
  end
end
