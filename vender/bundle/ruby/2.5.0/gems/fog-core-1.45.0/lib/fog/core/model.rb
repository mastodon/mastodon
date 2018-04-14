require "fog/core/deprecated_connection_accessors"
require "fog/core/cache"

module Fog
  class Model
    extend Fog::Attributes::ClassMethods
    include Fog::Attributes::InstanceMethods
    include Fog::Core::DeprecatedConnectionAccessors

    attr_accessor :collection
    attr_reader :service

    def initialize(new_attributes = {})
      # TODO: Remove compatibility with old connection option
      attribs = new_attributes.clone
      @service = attribs.delete(:service)
      if @service.nil? && attribs[:connection]
        Fog::Logger.deprecation("Passing :connection option is deprecated, use :service instead [light_black](#{caller.first})[/]")
        @service = attribs[:connection]
      end
      merge_attributes(attribs)
    end

    def cache
      Fog::Cache.new(self)
    end

    def inspect
      Fog::Formatador.format(self)
    end

    def ==(o)
      unless o.is_a?(Fog::Model)
        super
      else
        if (o.identity.nil? and self.identity.nil?)
          o.object_id == self.object_id
        else
          o.class == self.class and o.identity == self.identity
        end
      end
    end

    def reload
      requires :identity

      data = begin
        collection.get(identity)
      rescue Excon::Errors::SocketError
        nil
      end

      return unless data

      new_attributes = data.attributes
      merge_attributes(new_attributes)
      self
    end

    def to_json(_options = {})
      Fog::JSON.encode(attributes)
    end

    def symbolize_keys(hash)
      return nil if hash.nil?
      hash.reduce({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end

    def wait_for(timeout = Fog.timeout, interval = Fog.interval, &block)
      reload_has_succeeded = false
      duration = Fog.wait_for(timeout, interval) do # Note that duration = false if it times out
        if reload
          reload_has_succeeded = true
          instance_eval(&block)
        else
          false
        end
      end
      if reload_has_succeeded
        return duration # false if timeout; otherwise {:duration => elapsed time }
      else
        raise Fog::Errors::Error, "Reload failed, #{self.class} #{identity} not present."
      end
    end
  end
end
