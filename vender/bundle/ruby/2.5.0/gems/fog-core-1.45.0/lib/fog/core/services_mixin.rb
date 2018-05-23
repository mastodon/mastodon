module Fog
  module ServicesMixin
    def [](provider)
      new(:provider => provider)
    end

    def new(attributes)
      attributes    = attributes.dup # Prevent delete from having side effects
      provider      = attributes.delete(:provider).to_s.downcase.to_sym
      provider_name = Fog.providers[provider]

      raise ArgumentError, "#{provider} is not a recognized provider" unless providers.include?(provider)

      require_service_provider_library(service_name.downcase, provider)
      spc = service_provider_constant(service_name, provider_name)
      spc.new(attributes)
    rescue LoadError, NameError  # Only rescue errors in finding the libraries, allow connection errors through to the caller
      raise Fog::Service::NotFound, "#{provider} has no #{service_name.downcase} service"
    end

    def providers
      Fog.services[service_name.downcase.to_sym] || []
    end

    private

    def require_service_provider_library(service, provider)
      require "fog/#{provider}/#{service}"
    rescue LoadError  # Try to require the service provider in an alternate location
      require "fog/#{service}/#{provider}"
    end

    def service_provider_constant(service_name, provider_name)
      Fog.const_get(service_name).const_get(*const_get_args(provider_name))
    rescue NameError  # Try to find the constant from in an alternate location
      Fog.const_get(provider_name).const_get(*const_get_args(service_name))
    end

    # Ruby 1.8 does not support the second 'inherit' argument to #const_get
    def const_get_args(*args)
      if RUBY_VERSION < '1.9'
        args
      else
        args + [false]
      end
    end

    def service_name
      name.split("Fog::").last
    end
  end
end
