require 'spec_helper_integration'

feature 'Skip authorization form' do
  background do
    config_is_set(:authenticate_resource_owner) { User.first || redirect_to('/sign_in') }
    client_exists
    default_scopes_exist  :public
    optional_scopes_exist :write
  end

  context 'for previously authorized clients' do
    background do
      create_resource_owner
      sign_in
    end

    scenario 'skips the authorization and return a new grant code' do
      client_is_authorized(@client, @resource_owner, scopes: 'public')
      visit authorization_endpoint_url(client: @client)

      i_should_not_see 'Authorize'
      client_should_be_authorized @client
      i_should_be_on_client_callback @client
      url_should_have_param 'code', Doorkeeper::AccessGrant.first.token
    end

    scenario 'does not skip authorization when scopes differ (new request has fewer scopes)' do
      client_is_authorized(@client, @resource_owner, scopes: 'public write')
      visit authorization_endpoint_url(client: @client, scope: 'public')
      i_should_see 'Authorize'
    end

    scenario 'does not skip authorization when scopes differ (new request has more scopes)' do
      client_is_authorized(@client, @resource_owner, scopes: 'public write')
      visit authorization_endpoint_url(client: @client, scopes: 'public write email')
      i_should_see 'Authorize'
    end

    scenario 'creates grant with new scope when scopes differ' do
      client_is_authorized(@client, @resource_owner, scopes: 'public write')
      visit authorization_endpoint_url(client: @client, scope: 'public')
      click_on 'Authorize'
      access_grant_should_have_scopes :public
    end

    scenario 'doesn not skip authorization when scopes are greater' do
      client_is_authorized(@client, @resource_owner, scopes: 'public')
      visit authorization_endpoint_url(client: @client, scope: 'public write')
      i_should_see 'Authorize'
    end

    scenario 'creates grant with new scope when scopes are greater' do
      client_is_authorized(@client, @resource_owner, scopes: 'public')
      visit authorization_endpoint_url(client: @client, scope: 'public write')
      click_on 'Authorize'
      access_grant_should_have_scopes :public, :write
    end
  end
end
