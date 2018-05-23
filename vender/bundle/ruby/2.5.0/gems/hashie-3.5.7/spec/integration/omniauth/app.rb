require 'sinatra'
require 'omniauth'

class MyApplication < Sinatra::Base
  use Rack::Session::Cookie, secret: 'hashie integration tests'
  use OmniAuth::Strategies::Developer

  get '/' do
    'Hello World'
  end
end
