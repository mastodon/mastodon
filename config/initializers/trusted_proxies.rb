module Rack
  class Request
    def trusted_proxy?(ip)
      if Rails.application.config.action_dispatch.trusted_proxies.nil?
        super
      else
        Rails.application.config.action_dispatch.trusted_proxies.any? { |proxy| proxy === ip }
      end
    end
  end
end
