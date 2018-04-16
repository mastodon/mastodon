require 'rack/lobster'

use Rack::ShowExceptions
use Rack::Auth::Basic, "Lobster 2.0" do |username, password|
  Rack::Utils.secure_compare('secret', password)
end

run Rack::Lobster.new
