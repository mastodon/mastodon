require 'rack/handler/puma'

module Rack::Handler
  def self.default(options = {})
    Rack::Handler::Puma
  end
end
