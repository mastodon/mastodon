require 'minitest/autorun'
require 'rack/handler'

class Rack::Handler::Lobster; end
class RockLobster; end

describe Rack::Handler do
  it "has registered default handlers" do
    Rack::Handler.get('cgi').must_equal Rack::Handler::CGI
    Rack::Handler.get('webrick').must_equal Rack::Handler::WEBrick

    begin
      Rack::Handler.get('fastcgi').must_equal Rack::Handler::FastCGI
    rescue LoadError
    end
  end

  it "raise LoadError if handler doesn't exist" do
    lambda {
      Rack::Handler.get('boom')
    }.must_raise(LoadError)

    lambda {
      Rack::Handler.get('Object')
    }.must_raise(LoadError)
  end

  it "get unregistered, but already required, handler by name" do
    Rack::Handler.get('Lobster').must_equal Rack::Handler::Lobster
  end

  it "register custom handler" do
    Rack::Handler.register('rock_lobster', 'RockLobster')
    Rack::Handler.get('rock_lobster').must_equal RockLobster
  end

  it "not need registration for properly coded handlers even if not already required" do
    begin
      $LOAD_PATH.push File.expand_path('../unregistered_handler', __FILE__)
      Rack::Handler.get('Unregistered').must_equal Rack::Handler::Unregistered
      lambda { Rack::Handler.get('UnRegistered') }.must_raise LoadError
      Rack::Handler.get('UnregisteredLongOne').must_equal Rack::Handler::UnregisteredLongOne
    ensure
      $LOAD_PATH.delete File.expand_path('../unregistered_handler', __FILE__)
    end
  end

  it "allow autoloaded handlers to be registered properly while being loaded" do
    path = File.expand_path('../registering_handler', __FILE__)
    begin
      $LOAD_PATH.push path
      Rack::Handler.get('registering_myself').must_equal Rack::Handler::RegisteringMyself
    ensure
      $LOAD_PATH.delete path
    end
  end
end
