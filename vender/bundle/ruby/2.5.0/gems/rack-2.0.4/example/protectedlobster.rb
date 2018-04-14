require 'rack'
require 'rack/lobster'

lobster = Rack::Lobster.new

protected_lobster = Rack::Auth::Basic.new(lobster) do |username, password|
  Rack::Utils.secure_compare('secret', password)
end

protected_lobster.realm = 'Lobster 2.0'

pretty_protected_lobster = Rack::ShowStatus.new(Rack::ShowExceptions.new(protected_lobster))

Rack::Server.start :app => pretty_protected_lobster, :Port => 9292
