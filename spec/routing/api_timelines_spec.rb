require 'rails_helper'

describe 'API timeline routes' do
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
