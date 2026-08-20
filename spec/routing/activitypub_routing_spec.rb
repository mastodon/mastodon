# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Routes under ap/' do
  it 'correctly handles numeric account ids' do
    expect(get('/ap/users/1234/statuses/5678')).to route_to('statuses#show', account_id: '1234', id: '5678')
  end

  it 'correctly handles the instance actor id' do
    expect(get('/ap/users/-99/statuses/5678')).to route_to('statuses#show', account_id: '-99', id: '5678')
  end

  it 'does not accept usernames' do
    expect(get('/ap/users/john/statuses/5678')).to_not route_to('statuses#show', account_id: 'john', id: '5678')
  end
end
