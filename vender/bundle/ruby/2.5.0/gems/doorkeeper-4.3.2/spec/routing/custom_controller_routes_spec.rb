require 'spec_helper_integration'

describe 'Custom controller for routes' do
  it 'GET /space/scope/authorize routes to custom authorizations controller' do
    expect(get('/inner_space/scope/authorize')).to route_to('custom_authorizations#new')
  end

  it 'POST /space/scope/authorize routes to custom authorizations controller' do
    expect(post('/inner_space/scope/authorize')).to route_to('custom_authorizations#create')
  end

  it 'DELETE /space/scope/authorize routes to custom authorizations controller' do
    expect(delete('/inner_space/scope/authorize')).to route_to('custom_authorizations#destroy')
  end

  it 'POST /space/scope/token routes to tokens controller' do
    expect(post('/inner_space/scope/token')).to route_to('custom_authorizations#create')
  end

  it 'GET /space/scope/applications routes to applications controller' do
    expect(get('/inner_space/scope/applications')).to route_to('custom_authorizations#index')
  end

  it 'GET /space/scope/token/info routes to the token_info controller' do
    expect(get('/inner_space/scope/token/info')).to route_to('custom_authorizations#show')
  end

  it 'GET /space/oauth/authorize routes to custom authorizations controller' do
    expect(get('/space/oauth/authorize')).to route_to('custom_authorizations#new')
  end

  it 'POST /space/oauth/authorize routes to custom authorizations controller' do
    expect(post('/space/oauth/authorize')).to route_to('custom_authorizations#create')
  end

  it 'DELETE /space/oauth/authorize routes to custom authorizations controller' do
    expect(delete('/space/oauth/authorize')).to route_to('custom_authorizations#destroy')
  end

  it 'POST /space/oauth/token routes to tokens controller' do
    expect(post('/space/oauth/token')).to route_to('custom_authorizations#create')
  end

  it 'POST /space/oauth/revoke routes to tokens controller' do
    expect(post('/space/oauth/revoke')).to route_to('custom_authorizations#revoke')
  end

  it 'POST /space/oauth/introspect routes to tokens controller' do
    expect(post('/space/oauth/introspect')).to route_to('custom_authorizations#introspect')
  end

  it 'GET /space/oauth/applications routes to applications controller' do
    expect(get('/space/oauth/applications')).to route_to('custom_authorizations#index')
  end

  it 'GET /space/oauth/token/info routes to the token_info controller' do
    expect(get('/space/oauth/token/info')).to route_to('custom_authorizations#show')
  end

  it 'POST /outer_space/oauth/token is not be routable' do
    expect(post('/outer_space/oauth/token')).not_to be_routable
  end

  it 'GET /outer_space/oauth/authorize routes to custom authorizations controller' do
    expect(get('/outer_space/oauth/authorize')).to be_routable
  end

  it 'GET /outer_space/oauth/applications is not routable' do
    expect(get('/outer_space/oauth/applications')).not_to be_routable
  end

  it 'GET /outer_space/oauth/token_info is not routable' do
    expect(get('/outer_space/oauth/token/info')).not_to be_routable
  end
end
