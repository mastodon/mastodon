require 'spec_helper_integration'

feature 'Private API' do
  background do
    @client   = FactoryBot.create(:application)
    @resource = User.create!(name: 'Joe', password: 'sekret')
    @token    = client_is_authorized(@client, @resource)
  end

  scenario 'client requests protected resource with valid token' do
    with_access_token_header @token.token
    visit '/full_protected_resources'
    expect(page.body).to have_content('index')
  end

  scenario 'client requests protected resource with disabled header authentication' do
    config_is_set :access_token_methods, [:from_access_token_param]
    with_access_token_header @token.token
    visit '/full_protected_resources'
    response_status_should_be 401
  end

  scenario 'client attempts to request protected resource with invalid token' do
    with_access_token_header 'invalid'
    visit '/full_protected_resources'
    response_status_should_be 401
  end

  scenario 'client attempts to request protected resource with expired token' do
    @token.update_attribute :expires_in, -100 # expires token
    with_access_token_header @token.token
    visit '/full_protected_resources'
    response_status_should_be 401
  end

  scenario 'client requests protected resource with permanent token' do
    @token.update_attribute :expires_in, nil # never expires
    with_access_token_header @token.token
    visit '/full_protected_resources'
    expect(page.body).to have_content('index')
  end

  scenario 'access token with no default scopes' do
    Doorkeeper.configuration.instance_eval {
      @default_scopes = Doorkeeper::OAuth::Scopes.from_array([:public])
      @scopes = default_scopes + optional_scopes
    }
    @token.update_attribute :scopes, 'dummy'
    with_access_token_header @token.token
    visit '/full_protected_resources'
    response_status_should_be 403
  end

  scenario 'access token with no allowed scopes' do
    @token.update_attribute :scopes, nil
    with_access_token_header @token.token
    visit '/full_protected_resources/1.json'
    response_status_should_be 403
  end

  scenario 'access token with one of allowed scopes' do
    @token.update_attribute :scopes, 'admin'
    with_access_token_header @token.token
    visit '/full_protected_resources/1.json'
    expect(page.body).to have_content('show')
  end

  scenario 'access token with another of allowed scopes' do
    @token.update_attribute :scopes, 'write'
    with_access_token_header @token.token
    visit '/full_protected_resources/1.json'
    expect(page.body).to have_content('show')
  end

  scenario 'access token with both allowed scopes' do
    @token.update_attribute :scopes, 'write admin'
    with_access_token_header @token.token
    visit '/full_protected_resources/1.json'
    expect(page.body).to have_content('show')
  end
end
