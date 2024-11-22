# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FollowingAccountsController' do
  describe 'The following_accounts route' do
    it "returns a http 'moved_permanently' code" do
      get '/users/:username/following'

      expect(response).to have_http_status(301)
    end
  end
end
