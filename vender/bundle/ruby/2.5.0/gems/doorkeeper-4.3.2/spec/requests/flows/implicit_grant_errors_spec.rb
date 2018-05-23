require 'spec_helper_integration'

feature 'Implicit Grant Flow Errors' do
  background do
    config_is_set(:authenticate_resource_owner) { User.first || redirect_to('/sign_in') }
    config_is_set(:grant_flows, ["implicit"])
    client_exists
    create_resource_owner
    sign_in
  end

  after do
    access_token_should_not_exist
  end

  [
    [:client_id,     :invalid_client],
    [:redirect_uri,  :invalid_redirect_uri]
  ].each do |error|
    scenario "displays #{error.last} error for invalid #{error.first}" do
      visit authorization_endpoint_url(client: @client, error.first => 'invalid', response_type: 'token')
      i_should_not_see 'Authorize'
      i_should_see_translated_error_message error.last
    end

    scenario "displays #{error.last} error when #{error.first} is missing" do
      visit authorization_endpoint_url(client: @client, error.first => '', response_type: 'token')
      i_should_not_see 'Authorize'
      i_should_see_translated_error_message error.last
    end
  end
end
