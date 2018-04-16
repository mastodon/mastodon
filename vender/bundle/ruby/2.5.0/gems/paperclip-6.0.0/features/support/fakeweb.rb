require 'fake_web'

FakeWeb.allow_net_connect = false

module FakeWeb
  class StubSocket
    def read_timeout=(_ignored)
    end

    def continue_timeout=(_ignored)
    end
  end
end
