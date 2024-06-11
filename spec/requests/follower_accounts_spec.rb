# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FollowerAccountsController' do
  describe 'The follower_accounts route' do
    it "returns a http 'moved_permanently' code" do
      get '/users/:username/followers'

      expect(response).to have_http_status(301)
    end
  end
end
