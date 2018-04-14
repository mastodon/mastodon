require 'spec_helper_integration'

feature 'Authorization endpoint' do
  background do
    config_is_set(:authenticate_resource_owner) { User.first || redirect_to('/sign_in') }
    client_exists(name: 'MyApp')
  end

  scenario 'requires resource owner to be authenticated' do
    visit authorization_endpoint_url(client: @client)
    i_should_see 'Sign in'
    i_should_be_on '/'
  end

  context 'with authenticated resource owner' do
    background do
      create_resource_owner
      sign_in
    end

    scenario 'displays the authorization form' do
      visit authorization_endpoint_url(client: @client)
      i_should_see 'Authorize MyApp to use your account?'
    end

    scenario 'displays all requested scopes' do
      default_scopes_exist :public
      optional_scopes_exist :write
      visit authorization_endpoint_url(client: @client, scope: 'public write')
      i_should_see 'Access your public data'
      i_should_see 'Update your data'
    end
  end

  context 'with a invalid request' do
    background do
      create_resource_owner
      sign_in
    end

    scenario 'displays the related error' do
      visit authorization_endpoint_url(client: @client, response_type: '')
      i_should_not_see 'Authorize'
      i_should_see_translated_error_message :unsupported_response_type
    end

    scenario "displays unsupported_response_type error when using a disabled response type" do
      config_is_set(:grant_flows, ['implicit'])
      visit authorization_endpoint_url(client: @client, response_type: 'code')
      i_should_not_see "Authorize"
      i_should_see_translated_error_message :unsupported_response_type
    end
  end

  context 'forgery protection enabled' do
    background do
      create_resource_owner
      sign_in
    end

    scenario 'raises exception on forged requests' do
      allowing_forgery_protection do
        expect {
          page.driver.post authorization_endpoint_url(client_id: @client.uid,
                                                      redirect_uri: @client.redirect_uri,
                                                      response_type:  'code')
        }.to raise_error(ActionController::InvalidAuthenticityToken)
      end
    end
  end
end
