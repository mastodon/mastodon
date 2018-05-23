require 'http_accept_language'
require 'rack/test'
require 'json'

class TestRackApp

  def call(env)
    request = Rack::Request.new(env)
    http_accept_language = env.http_accept_language
    result = {
      :user_preferred_languages => http_accept_language.user_preferred_languages,
    }
    if request.params['preferred']
      result[:preferred_language_from] = http_accept_language.preferred_language_from(request.params['preferred'])
    end
    [ 200, {}, [ JSON.generate(result) ]]
  end

end

describe "Rack integration" do
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use HttpAcceptLanguage::Middleware
      run TestRackApp.new
    end.to_app
  end

  it "handles reuse of the env instance" do
    env = { "HTTP_ACCEPT_LANGUAGE" => "en" }
    app = lambda { |env| env }
    middleware = HttpAcceptLanguage::Middleware.new(app)
    middleware.call(env)
    expect(env.http_accept_language.user_preferred_languages).to eq %w{en}
    env["HTTP_ACCEPT_LANGUAGE"] = "de"
    middleware.call(env)
    expect(env.http_accept_language.user_preferred_languages).to eq %w{de}
  end

  it "decodes the HTTP_ACCEPT_LANGUAGE header" do
    request_with_header 'en-us,en-gb;q=0.8,en;q=0.6,es-419'
    expect(r['user_preferred_languages']).to eq %w{en-US es-419 en-GB en}
  end

  it "finds the first available language" do
    request_with_header 'en-us,en-gb;q=0.8,en;q=0.6,es-419', :preferred => %w(en en-GB)
    expect(r['preferred_language_from']).to eq 'en-GB'
  end

  def request_with_header(header, params = {})
    get "/", params, 'HTTP_ACCEPT_LANGUAGE' => header
  end

  def r
    JSON.parse(last_response.body)
  end

end
