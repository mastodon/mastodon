require 'minitest/autorun'
require 'rack/auth/digest/md5'
require 'rack/lint'
require 'rack/mock'

describe Rack::Auth::Digest::MD5 do
  def realm
    'WallysWorld'
  end

  def unprotected_app
    Rack::Lint.new lambda { |env|
      friend = Rack::Utils.parse_query(env["QUERY_STRING"])["friend"]
      [ 200, {'Content-Type' => 'text/plain'}, ["Hi #{env['REMOTE_USER']}#{friend ? " and #{friend}" : ''}"] ]
    }
  end

  def protected_app
    Rack::Auth::Digest::MD5.new(unprotected_app, :realm => realm, :opaque => 'this-should-be-secret') do |username|
      { 'Alice' => 'correct-password' }[username]
    end
  end

  def protected_app_with_hashed_passwords
    app = Rack::Auth::Digest::MD5.new(unprotected_app) do |username|
      username == 'Alice' ? Digest::MD5.hexdigest("Alice:#{realm}:correct-password") : nil
    end
    app.realm = realm
    app.opaque = 'this-should-be-secret'
    app.passwords_hashed = true
    app
  end

  def partially_protected_app
    Rack::URLMap.new({
      '/' => unprotected_app,
      '/protected' => protected_app
    })
  end

  def protected_app_with_method_override
    Rack::MethodOverride.new(protected_app)
  end

  before do
    @request = Rack::MockRequest.new(protected_app)
  end

  def request(method, path, headers = {}, &block)
    response = @request.request(method, path, headers)
    block.call(response) if block
    return response
  end

  class MockDigestRequest
    def initialize(params)
      @params = params
    end
    def method_missing(sym)
      if @params.has_key? k = sym.to_s
        return @params[k]
      end
      super
    end
    def method
      @params['method']
    end
    def response(password)
      Rack::Auth::Digest::MD5.new(nil).send :digest, self, password
    end
  end

  def request_with_digest_auth(method, path, username, password, options = {}, &block)
    request_options = {}
    request_options[:input] = options.delete(:input) if options.include? :input

    response = request(method, path, request_options)

    return response unless response.status == 401

    if wait = options.delete(:wait)
      sleep wait
    end

    challenge = response['WWW-Authenticate'].split(' ', 2).last

    params = Rack::Auth::Digest::Params.parse(challenge)

    params['username'] = username
    params['nc'] = '00000001'
    params['cnonce'] = 'nonsensenonce'
    params['uri'] = path

    params['method'] = method

    params.update options

    params['response'] = MockDigestRequest.new(params).response(password)

    request(method, path, request_options.merge('HTTP_AUTHORIZATION' => "Digest #{params}"), &block)
  end

  def assert_digest_auth_challenge(response)
    response.must_be :client_error?
    response.status.must_equal 401
    response.must_include 'WWW-Authenticate'
    response.headers['WWW-Authenticate'].must_match(/^Digest /)
    response.body.must_be :empty?
  end

  def assert_bad_request(response)
    response.must_be :client_error?
    response.status.must_equal 400
    response.wont_include 'WWW-Authenticate'
  end

  it 'challenge when no credentials are specified' do
    request 'GET', '/' do |response|
      assert_digest_auth_challenge response
    end
  end

  it 'return application output if correct credentials given' do
    request_with_digest_auth 'GET', '/', 'Alice', 'correct-password' do |response|
      response.status.must_equal 200
      response.body.to_s.must_equal 'Hi Alice'
    end
  end

  it 'return application output if correct credentials given (hashed passwords)' do
    @request = Rack::MockRequest.new(protected_app_with_hashed_passwords)

    request_with_digest_auth 'GET', '/', 'Alice', 'correct-password' do |response|
      response.status.must_equal 200
      response.body.to_s.must_equal 'Hi Alice'
    end
  end

  it 'rechallenge if incorrect username given' do
    request_with_digest_auth 'GET', '/', 'Bob', 'correct-password' do |response|
      assert_digest_auth_challenge response
    end
  end

  it 'rechallenge if incorrect password given' do
    request_with_digest_auth 'GET', '/', 'Alice', 'wrong-password' do |response|
      assert_digest_auth_challenge response
    end
  end

  it 'rechallenge if incorrect user and blank password given' do
    request_with_digest_auth 'GET', '/', 'Bob', '' do |response|
      assert_digest_auth_challenge response
    end
  end

  it 'not rechallenge if nonce is not stale' do
    begin
      Rack::Auth::Digest::Nonce.time_limit = 10

      request_with_digest_auth 'GET', '/', 'Alice', 'correct-password', :wait => 1 do |response|
        response.status.must_equal 200
        response.body.to_s.must_equal 'Hi Alice'
        response.headers['WWW-Authenticate'].wont_match(/\bstale=true\b/)
      end
    ensure
      Rack::Auth::Digest::Nonce.time_limit = nil
    end
  end

  it 'rechallenge with stale parameter if nonce is stale' do
    begin
      Rack::Auth::Digest::Nonce.time_limit = 1

      request_with_digest_auth 'GET', '/', 'Alice', 'correct-password', :wait => 2 do |response|
        assert_digest_auth_challenge response
        response.headers['WWW-Authenticate'].must_match(/\bstale=true\b/)
      end
    ensure
      Rack::Auth::Digest::Nonce.time_limit = nil
    end
  end

  it 'return 400 Bad Request if incorrect qop given' do
    request_with_digest_auth 'GET', '/', 'Alice', 'correct-password', 'qop' => 'auth-int' do |response|
      assert_bad_request response
    end
  end

  it 'return 400 Bad Request if incorrect uri given' do
    request_with_digest_auth 'GET', '/', 'Alice', 'correct-password', 'uri' => '/foo' do |response|
      assert_bad_request response
    end
  end

  it 'return 400 Bad Request if different auth scheme used' do
    request 'GET', '/', 'HTTP_AUTHORIZATION' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==' do |response|
      assert_bad_request response
    end
  end

  it 'not require credentials for unprotected path' do
    @request = Rack::MockRequest.new(partially_protected_app)
    request 'GET', '/' do |response|
      response.must_be :ok?
    end
  end

  it 'challenge when no credentials are specified for protected path' do
    @request = Rack::MockRequest.new(partially_protected_app)
    request 'GET', '/protected' do |response|
      assert_digest_auth_challenge response
    end
  end

  it 'return application output if correct credentials given for protected path' do
    @request = Rack::MockRequest.new(partially_protected_app)
    request_with_digest_auth 'GET', '/protected', 'Alice', 'correct-password' do |response|
      response.status.must_equal 200
      response.body.to_s.must_equal 'Hi Alice'
    end
  end

  it 'return application output when used with a query string and path as uri' do
    @request = Rack::MockRequest.new(partially_protected_app)
    request_with_digest_auth 'GET', '/protected?friend=Mike', 'Alice', 'correct-password' do |response|
      response.status.must_equal 200
      response.body.to_s.must_equal 'Hi Alice and Mike'
    end
  end

  it 'return application output when used with a query string and fullpath as uri' do
    @request = Rack::MockRequest.new(partially_protected_app)
    qs_uri = '/protected?friend=Mike'
    request_with_digest_auth 'GET', qs_uri, 'Alice', 'correct-password', 'uri' => qs_uri do |response|
      response.status.must_equal 200
      response.body.to_s.must_equal 'Hi Alice and Mike'
    end
  end

  it 'return application output if correct credentials given for POST' do
    request_with_digest_auth 'POST', '/', 'Alice', 'correct-password' do |response|
      response.status.must_equal 200
      response.body.to_s.must_equal 'Hi Alice'
    end
  end

  it 'return application output if correct credentials given for PUT (using method override of POST)' do
    @request = Rack::MockRequest.new(protected_app_with_method_override)
    request_with_digest_auth 'POST', '/', 'Alice', 'correct-password', :input => "_method=put" do |response|
      response.status.must_equal 200
      response.body.to_s.must_equal 'Hi Alice'
    end
  end

  it 'takes realm as optional constructor arg' do
    app = Rack::Auth::Digest::MD5.new(unprotected_app, realm) { true }
    realm.must_equal app.realm
  end
end
