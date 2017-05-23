require 'rails_helper'

describe 'API routes' do
  describe 'credentials routes' do
    it 'routes verify credentials' do
      expect(get('/api/v1/accounts/verify_credentials')).
        to route_to('api/v1/accounts/credentials#show')
    end

    it 'routes update credentials' do
      expect(patch('/api/v1/accounts/update_credentials')).
        to route_to('api/v1/accounts/credentials#update')
    end

    it 'routes account statuses' do
      expect(get('/api/v1/accounts/user/statuses')).
        to route_to('api/v1/accounts/statuses#index', account_id: 'user')
    end

    it 'routes account search' do
      expect(get('/api/v1/accounts/search')).
        to route_to('api/v1/accounts/search#show')
    end
  end
end
