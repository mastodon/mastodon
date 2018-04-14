module Fog
  module Account
    extend Fog::ServicesMixin

    def self.new(orig_attributes)
      attributes = orig_attributes.dup
      provider = attributes.delete(:provider).to_s.downcase.to_sym

      if provider == :stormondemand
        require "fog/account/storm_on_demand"
        Fog::Account::StormOnDemand.new(attributes)
      else
        super(orig_attributes)
      end
    end

    def self.providers
      Fog.services[:account] || []
    end
  end
end
