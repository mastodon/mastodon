module RequestSpecHelper
  def i_should_see(content)
    expect(page).to have_content(content)
  end

  def i_should_not_see(content)
    expect(page).to have_no_content(content)
  end

  def i_should_be_on(path)
    expect(current_path).to eq(path)
  end

  def url_should_have_param(param, value)
    expect(current_params[param]).to eq(value)
  end

  def url_should_not_have_param(param)
    expect(current_params).not_to have_key(param)
  end

  def current_params
    Rack::Utils.parse_query(current_uri.query)
  end

  def current_uri
    URI.parse(page.current_url)
  end

  def request_response
    respond_to?(:response) ? response : page.driver.response
  end

  def json_response
    JSON.parse(request_response.body)
  end

  def should_have_header(header, value)
    expect(headers[header]).to eq(value)
  end

  def with_access_token_header(token)
    with_header 'Authorization', "Bearer #{token}"
  end

  def with_header(header, value)
    page.driver.header header, value
  end

  def basic_auth_header_for_client(client)
    ActionController::HttpAuthentication::Basic.encode_credentials client.uid, client.secret
  end

  def should_have_json(key, value)
    expect(json_response.fetch(key)).to eq(value)
  end

  def should_have_json_within(key, value, range)
    expect(json_response.fetch(key)).to be_within(range).of(value)
  end

  def should_not_have_json(key)
    expect(json_response).not_to have_key(key)
  end

  def sign_in
    visit '/'
    click_on 'Sign in'
  end

  def create_access_token(authorization_code, client)
    page.driver.post token_endpoint_url(code: authorization_code, client: client)
  end

  def i_should_see_translated_error_message(key)
    i_should_see translated_error_message(key)
  end

  def translated_error_message(key)
    I18n.translate key, scope: %i[doorkeeper errors messages]
  end

  def response_status_should_be(status)
    expect(request_response.status.to_i).to eq(status)
  end
end

RSpec.configuration.send :include, RequestSpecHelper
