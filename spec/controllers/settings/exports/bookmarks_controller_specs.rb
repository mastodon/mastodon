require 'rails_helper'

describe Settings::Exports::BookmarksController do
  render_views

  describe 'GET #index' do
    it 'returns a csv of the bookmarked toots' do
      user = Fabricate(:user)
      user.account.bookmarks.create!(status: Fabricate(:status, uri: 'https://foo.bar/statuses/1312'))

      sign_in user, scope: :user
      get :index, format: :csv

      expect(response.body).to eq "https://foo.bar/statuses/1312\n"
    end
  end
end
