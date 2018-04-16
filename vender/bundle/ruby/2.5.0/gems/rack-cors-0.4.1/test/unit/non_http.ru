require 'rack/cors'

use Rack::Cors do
  allow do
    origins 'com.company.app'
    resource '/public'
  end
end
