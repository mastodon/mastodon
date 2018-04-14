module Fog
  module Monitoring
    extend Fog::ServicesMixin

    def self.new(orig_attributes)
      attributes = orig_attributes.dup
      provider = attributes.delete(:provider).to_s.downcase.to_sym
      if provider == :stormondemand
        require "fog/monitoring/storm_on_demand"
        Fog::Monitoring::StormOnDemand.new(attributes)
      else
        super(orig_attributes)
      end
    end
  end
end
