require 'rails_helper'

describe Settings::Exports::FollowingTagsController do
  render_views

  describe 'GET #index' do
    it 'returns a csv of the following tags' do
      follow = Fabricate(:tag_follow)
      _unfollowed = Fabricate(:tag)

      sign_in follow.account.user, scope: :user
      get :index, format: :csv

      expect(response.body).to eq "Tag\n#{follow.tag.name}\n"
    end
  end
end
