require 'rails_helper'

describe 'Routes under accounts/' do
  describe 'the route for accounts who are followers of an account' do
    it 'routes to the followers action with the right username' do
      expect(get('/users/name/followers')).
        to route_to('follower_accounts#index', account_username: 'name')
    end
  end

  describe 'the route for accounts who are followed by an account' do
    it 'routes to the following action with the right username' do
      expect(get('/users/name/following')).
        to route_to('following_accounts#index', account_username: 'name')
    end
  end
end
