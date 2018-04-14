# Rails 5 deprecates calling HTTP action methods with positional arguments
# in favor of keyword arguments. However, the keyword argument form is only
# supported in Rails 5+. Since we support back to 4, we need some sort of shim
# to avoid super noisy deprecations when running tests.
module RoutingHTTPMethodShim
  def get(path, params = {}, headers = nil)
    super(path, params: params, headers: headers)
  end

  def post(path, params = {}, headers = nil)
    super(path, params: params, headers: headers)
  end

  def put(path, params = {}, headers = nil)
    super(path, params: params, headers: headers)
  end
end

module ControllerHTTPMethodShim
  def get(path, params = {})
    super(path, params: params)
  end

  def post(path, params = {})
    super(path, params: params)
  end

  def put(path, params = {})
    super(path, params: params)
  end
end

if ::Rails::VERSION::MAJOR >= 5
  RSpec.configure do |config|
    config.include ControllerHTTPMethodShim, type: :controller
    config.include RoutingHTTPMethodShim, type: :request
  end
end
