module Fog
  module DNS
    extend Fog::ServicesMixin

    def self.new(orig_attributes)
      attributes = orig_attributes.dup # prevent delete from having side effects
      case attributes.delete(:provider).to_s.downcase.to_sym
      when :stormondemand
        require "fog/dns/storm_on_demand"
        Fog::DNS::StormOnDemand.new(attributes)
      else
        super(orig_attributes)
      end
    end

    def self.zones
      zones = []
      providers.each do |provider|
        begin
          zones.concat(self[provider].zones)
        rescue # ignore any missing credentials/etc
        end
      end
      zones
    end
  end
end
