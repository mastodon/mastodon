class FakeService < Fog::Service
  class Real
    def request
    end
  end

  class Mock
    def request
    end
  end
end