class FakeService < Fog::Service
  class Real
    def initialize(_options)
    end
  end

  class Mock
    def initialize(_options)
    end
  end

  model_path File.join(File.dirname(__FILE__), "models")
  model :model
  collection :collection

  request_path File.join(File.dirname(__FILE__), "requests")
  request :request
end