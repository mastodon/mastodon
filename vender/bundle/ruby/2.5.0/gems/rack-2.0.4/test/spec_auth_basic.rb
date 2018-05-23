require 'minitest/autorun'
require 'rack/auth/basic'
require 'rack/lint'
require 'rack/mock'

describe Rack::Auth::Basic do
  def realm
    'WallysWorld'
  end

  def unprotected_app
    Rack::Lint.new lambda { |env|
      [ 200, {'Content-Type' => 'text/plain'}, ["Hi #{env['REMOTE_USER']}"] ]
    }
  end

  def protected_app
    app = Rack::Auth::Basic.new(unprotected_app) { |username, password| 'Boss' == username }
    app.realm = realm
    app
  end

  before do
    @request = Rack::MockRequest.new(protected_app)
  end

  def request_with_basic_auth(username, password, &block)
    request 'HTTP_AUTHORIZATION' => 'Basic ' + ["#{username}:#{password}"].pack("m*"), &block
  end

  def request(headers = {})
    yield @request.get('/', headers)
  end

  def assert_basic_auth_challenge(response)
    response.must_be :client_error?
    response.status.must_equal 401
    response.must_include 'WWW-Authenticate'
    response.headers['WWW-Authenticate'].must_match(/Basic realm="#{Regexp.escape(realm)}"/)
    response.body.must_be :empty?
  end

  it 'challenge correctly when no credentials are specified' do
    request do |response|
      assert_basic_auth_challenge response
    end
  end

  it 'rechallenge if incorrect credentials are specified' do
    request_with_basic_auth 'joe', 'password' do |response|
      assert_basic_auth_challenge response
    end
  end

  it 'return application output if correct credentials are specified' do
    request_with_basic_auth 'Boss', 'password' do |response|
      response.status.must_equal 200
      response.body.to_s.must_equal 'Hi Boss'
    end
  end

  it 'return 400 Bad Request if different auth scheme used' do
    request 'HTTP_AUTHORIZATION' => 'Digest params' do |response|
      response.must_be :client_error?
      response.status.must_equal 400
      response.wont_include 'WWW-Authenticate'
    end
  end

  it 'return 400 Bad Request for a malformed authorization header' do
    request 'HTTP_AUTHORIZATION' => '' do |response|
      response.must_be :client_error?
      response.status.must_equal 400
      response.wont_include 'WWW-Authenticate'
    end
  end

  it 'return 401 Bad Request for a nil authorization header' do
    request 'HTTP_AUTHORIZATION' => nil do |response|
      response.must_be :client_error?
      response.status.must_equal 401
    end
  end

  it 'takes realm as optional constructor arg' do
    app = Rack::Auth::Basic.new(unprotected_app, realm) { true }
    realm.must_equal app.realm
  end
end
