require 'spec_helper_integration'

describe 'Default routes' do
  it 'GET /oauth/authorize routes to authorizations controller' do
    expect(get('/oauth/authorize')).to route_to('doorkeeper/authorizations#new')
  end

  it 'POST /oauth/authorize routes to authorizations controller' do
    expect(post('/oauth/authorize')).to route_to('doorkeeper/authorizations#create')
  end

  it 'DELETE /oauth/authorize routes to authorizations controller' do
    expect(delete('/oauth/authorize')).to route_to('doorkeeper/authorizations#destroy')
  end

  it 'POST /oauth/token routes to tokens controller' do
    expect(post('/oauth/token')).to route_to('doorkeeper/tokens#create')
  end

  it 'POST /oauth/revoke routes to tokens controller' do
    expect(post('/oauth/revoke')).to route_to('doorkeeper/tokens#revoke')
  end

  it 'POST /oauth/introspect routes to tokens controller' do
    expect(post('/oauth/introspect')).to route_to('doorkeeper/tokens#introspect')
  end

  it 'GET /oauth/applications routes to applications controller' do
    expect(get('/oauth/applications')).to route_to('doorkeeper/applications#index')
  end

  it 'GET /oauth/authorized_applications routes to authorized applications controller' do
    expect(get('/oauth/authorized_applications')).to route_to('doorkeeper/authorized_applications#index')
  end

  it 'GET /oauth/token/info route to authorized tokeninfo controller' do
    expect(get('/oauth/token/info')).to route_to('doorkeeper/token_info#show')
  end
end
