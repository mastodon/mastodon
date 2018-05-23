require 'spec_helper_integration'

describe 'Scoped routes' do
  it 'GET /scope/authorize routes to authorizations controller' do
    expect(get('/scope/authorize')).to route_to('doorkeeper/authorizations#new')
  end

  it 'POST /scope/authorize routes to authorizations controller' do
    expect(post('/scope/authorize')).to route_to('doorkeeper/authorizations#create')
  end

  it 'DELETE /scope/authorize routes to authorizations controller' do
    expect(delete('/scope/authorize')).to route_to('doorkeeper/authorizations#destroy')
  end

  it 'POST /scope/token routes to tokens controller' do
    expect(post('/scope/token')).to route_to('doorkeeper/tokens#create')
  end

  it 'GET /scope/applications routes to applications controller' do
    expect(get('/scope/applications')).to route_to('doorkeeper/applications#index')
  end

  it 'GET /scope/authorized_applications routes to authorized applications controller' do
    expect(get('/scope/authorized_applications')).to route_to('doorkeeper/authorized_applications#index')
  end

  it 'GET /scope/token/info route to authorzed tokeninfo controller' do
    expect(get('/scope/token/info')).to route_to('doorkeeper/token_info#show')
  end
end
