require_relative "support/namespace"


# This provides compatibility with versions <= 0.3.x where timeout settings were class-level.
# Beware that, unintuitively, a class-level setting overrides local settings for all instances.
# Generally speaking, everyone should migrate to instance-level settings.

module Rack::Timeout::ClassLevelProperties

  module ClassMethods
    attr_accessor :service_timeout, :wait_timeout, :wait_overtime, :service_past_wait
    alias_method :timeout=, :service_timeout=

    [ :service_timeout=,
      :timeout=,
      :wait_timeout=,
      :wait_overtime=,
      :service_past_wait=,
    ].each do |isetter|
      setter = instance_method(isetter)
      define_method(isetter) do |x|
        defined?(Rails) or warn "`Rack::Timeout.#{isetter}`: class-level settings are deprecated. See README for examples on using the middleware initializer instead."
        setter.bind(self).call(x)
      end
    end
  end

  module InstanceMethods

    [:service_timeout, :wait_timeout, :wait_overtime].each do |m|
      define_method(m) { read_timeout_property self.class.send(m), super() }
    end

    def service_past_wait
      self.class.service_past_wait || super
    end
  end

end


Rack::Timeout.extend  Rack::Timeout::ClassLevelProperties::ClassMethods
Rack::Timeout.send :prepend, Rack::Timeout::ClassLevelProperties::InstanceMethods
