module Fog
  module VPN
    extend Fog::ServicesMixin

    def self.new(orig_attributes)
      attributes = orig_attributes.dup
      provider = attributes.delete(:provider).to_s.downcase.to_sym

      if provider == :stormondemand
        require "fog/vpn/storm_on_demand"
        Fog::VPN::StormOnDemand.new(attributes)
      else
        super(orig_attributes)
      end
    end
  end
end
