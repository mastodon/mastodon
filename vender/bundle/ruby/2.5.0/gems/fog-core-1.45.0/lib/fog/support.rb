module Fog
  module Support
    extend Fog::ServicesMixin

    def self.new(orig_attributes)
      attributes = orig_attributes.dup
      provider = attributes.delete(:provider).to_s.downcase.to_sym

      if provider == :stormondemand
        require "fog/support/storm_on_demand"
        Fog::Support::StormOnDemand.new(attributes)
      else
        super(orig_attributes)
      end
    end
  end
end
