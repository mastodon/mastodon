require 'spec_helper_integration'

feature 'Authorization Code Flow Errors' do
  let(:client_params) { {} }
  background do
    config_is_set(:authenticate_resource_owner) { User.first || redirect_to('/sign_in') }
    client_exists client_params
    create_resource_owner
    sign_in
  end

  after do
    access_grant_should_not_exist
  end

  context "with a client trying to xss resource owner" do
    let(:client_name) { "<div id='xss'>XSS</div>" }
    let(:client_params) { { name: client_name } }
    scenario "resource owner visit authorization endpoint" do
      visit authorization_endpoint_url(client: @client)
      expect(page).not_to have_css("#xss")
    end
  end

  context 'when access was denied' do
    scenario 'redirects with error' do
      visit authorization_endpoint_url(client: @client)
      click_on 'Deny'

      i_should_be_on_client_callback @client
      url_should_not_have_param 'code'
      url_should_have_param 'error', 'access_denied'
      url_should_have_param 'error_description', translated_error_message(:access_denied)
    end

    scenario 'redirects with state parameter' do
      visit authorization_endpoint_url(client: @client, state: 'return-this')
      click_on 'Deny'

      i_should_be_on_client_callback @client
      url_should_not_have_param 'code'
      url_should_have_param 'state', 'return-this'
    end
  end
end

describe 'Authorization Code Flow Errors', 'after authorization' do
  before do
    client_exists
    authorization_code_exists application: @client
  end

  it 'returns :invalid_grant error when posting an already revoked grant code' do
    # First successful request
    post token_endpoint_url(code: @authorization.token, client: @client)

    # Second attempt with same token
    expect do
      post token_endpoint_url(code: @authorization.token, client: @client)
    end.to_not change { Doorkeeper::AccessToken.count }

    should_not_have_json 'access_token'
    should_have_json 'error', 'invalid_grant'
    should_have_json 'error_description', translated_error_message('invalid_grant')
  end

  it 'returns :invalid_grant error for invalid grant code' do
    post token_endpoint_url(code: 'invalid', client: @client)

    access_token_should_not_exist

    should_not_have_json 'access_token'
    should_have_json 'error', 'invalid_grant'
    should_have_json 'error_description', translated_error_message('invalid_grant')
  end
end
