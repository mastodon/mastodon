module Fog
  module Network
    extend Fog::ServicesMixin

    def self.new(orig_attributes)
      attributes = orig_attributes.dup # Prevent delete from having side effects
      provider = attributes.delete(:provider).to_s.downcase.to_sym

      if provider == :stormondemand
        require "fog/network/storm_on_demand"
        return Fog::Network::StormOnDemand.new(attributes)
      else
        super(orig_attributes)
      end
    end
  end
end
