module Rack
  class Request
    def trusted_proxy?(ip)
      Rails.application.config.action_dispatch.trusted_proxies.any? { |proxy| proxy === ip }
    end
  end
end
