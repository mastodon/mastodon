require 'rails_helper'

describe 'API routes' do
  describe 'Credentials routes' do
    it 'routes to verify credentials' do
      expect(get('/api/v1/accounts/verify_credentials')).
        to route_to('api/v1/accounts/credentials#show')
    end

    it 'routes to update credentials' do
      expect(patch('/api/v1/accounts/update_credentials')).
        to route_to('api/v1/accounts/credentials#update')
    end
  end

  describe 'Account routes' do
    it 'routes to statuses' do
      expect(get('/api/v1/accounts/user/statuses')).
        to route_to('api/v1/accounts/statuses#index', account_id: 'user')
    end

    it 'routes to followers' do
      expect(get('/api/v1/accounts/user/followers')).
        to route_to('api/v1/accounts/follower_accounts#index', account_id: 'user')
    end

    it 'routes to following' do
      expect(get('/api/v1/accounts/user/following')).
        to route_to('api/v1/accounts/following_accounts#index', account_id: 'user')
    end

    it 'routes to search' do
      expect(get('/api/v1/accounts/search')).
        to route_to('api/v1/accounts/search#show')
    end

    it 'routes to relationships' do
      expect(get('/api/v1/accounts/relationships')).
        to route_to('api/v1/accounts/relationships#index')
    end
  end
  
  describe 'Timeline routes' do
    it 'routes to home timeline' do
      expect(get('/api/v1/timelines/home')).
        to route_to('api/v1/timelines/home#show')
    end

    it 'routes to public timeline' do
      expect(get('/api/v1/timelines/public')).
        to route_to('api/v1/timelines/public#show')
    end

    it 'routes to tag timeline' do
      expect(get('/api/v1/timelines/tag/test')).
        to route_to('api/v1/timelines/tag#show', id: 'test')
    end
  end
end
