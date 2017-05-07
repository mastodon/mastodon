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
  end
end
