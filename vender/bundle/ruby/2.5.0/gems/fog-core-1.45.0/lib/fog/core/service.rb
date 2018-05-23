require "fog/core/utils"

module Fog
  def self.services
    @services ||= {}
  end

  class Service
    class Error < Fog::Errors::Error; end
    class NotFound < Fog::Errors::NotFound; end

    module NoLeakInspector
      def inspect
        "#<#{self.class}:#{object_id} #{(instance_variables - service.secrets).map { |iv| [iv, instance_variable_get(iv).inspect].join("=") }.join(" ")}>"
      end
    end

    module Collections
      def collections
        service.collections
      end

      def mocked_requests
        service.mocked_requests
      end

      def requests
        service.requests
      end
    end

    class << self
      def inherited(child)
        child.class_eval <<-EOS, __FILE__, __LINE__
          class Error < Fog::Service::Error; end
          class NotFound < Fog::Service::NotFound; end

          module Collections
            include Fog::Service::Collections

            def service
              #{child}
            end
          end

          def self.service
            #{child}
          end
        EOS
      end

      # {Fog::Service} is (unfortunately) both a builder class and the subclass for any fog service.
      #
      # Creating a {new} instance using the builder will return either an instance of
      # +Fog::<Service>::<Provider>::Real+ or +Fog::<Service>::<Provider>::Mock+ based on the value
      # of {Fog.mock?} when the builder is used.
      #
      # Each provider can require or recognize different settings (often prefixed with the providers
      # name). These settings map to keys in the +~/.fog+ file.
      #
      # Settings can be passed as either a Hash or an object that responds to +config_service?+ with
      # +true+. This object will be passed through unchanged to the +Real+ or +Mock+ service that is
      # created. It is up to providers to adapt services to use these config objects.
      #
      # @abstract Subclass and implement real or mock code
      #
      # @param [Hash,#config_service?] config
      #   Settings or an object used to build a service instance
      # @option config [Hash] :headers
      #   Passed to the underlying {Fog::Core::Connection} unchanged
      #
      # @return [Fog::Service::Provider::Real] if created while mocking is disabled
      # @return [Fog::Service::Provider::Mock] if created while mocking is enabled
      # @raise [ArgumentError] if a setting required by the provider was not passed in
      #
      # @example Minimal options (dependent on ~/.fog)
      #   @service = Fog::Compute::Example.new # => <#Fog::Compute::Example::Real>
      #
      # @example Mocked service
      #   Fog.mock!
      #   @service = Fog::Compute::Example.new # => <#Fog::Compute::Example::Mock>
      #
      # @example Configured using many options (options merged into ~/.fog)
      #   @options = {
      #     :example_username => "fog",
      #     :example_password => "fog"
      #   }
      #   @service = Fog::Compute::Example.new(@options)
      #
      # @example Configured using external config object (~/.fog ignored completely)
      #   @config = Fog::Example::Config.new(...)
      #   @service = Fog::Compute::Example.new(@config)
      #
      def new(config = {})
        if config.respond_to?(:config_service?) && config.config_service?
          cleaned_settings = config
        else
          cleaned_settings = handle_settings(config)
        end
        setup_requirements

        svc = service
        if Fog.mocking?
          while svc != Fog::Service
            service::Mock.send(:include, svc::Collections)
            svc = svc.superclass
          end
          service::Mock.new(cleaned_settings)
        else
          while svc != Fog::Service
            service::Real.send(:include, svc::Collections)
            svc = svc.superclass
          end
          service::Real.send(:include, service::NoLeakInspector)
          service::Real.new(cleaned_settings)
        end
      end

      # @deprecated
      def fetch_credentials(_options)
        # attempt to load credentials from config file
        Fog.credentials.reject { |key, _value| !(recognized | requirements).include?(key) }
      rescue ::Fog::Errors::LoadError
        # if there are no configured credentials, do nothing
        {}
      end

      def setup_requirements
        if superclass.respond_to?(:setup_requirements)
          superclass.setup_requirements
        end

        @required ||= false

        return false if @required

        require_models
        require_collections_and_define
        require_requests_and_mock
        @required = true
      end

      # @note This path is used to require model and collection files
      def model_path(new_path)
        @model_path = new_path
      end

      def collection(new_collection, path = nil)
        collection_files << [path, new_collection]
        collections << new_collection
      end

      def collection_files
        @collection_files ||= []
      end

      def collections
        @collections ||= []
      end

      def coerce_options(options)
        options.each do |key, value|
          value_string = value.to_s.downcase
          if value.nil?
            options.delete(key)
          elsif value_string.to_i.to_s == value
            options[key] = value.to_i
          else
            options[key] = case value_string
                           when "false"
                             false
                           when "true"
                             true
                           else
                             value
                           end
          end
        end
      end

      def mocked_requests
        @mocked_requests ||= []
      end

      def model(new_model, path = nil)
        model_files << [path, new_model]
        models << [new_model]
      end

      def model_files
        @model_files ||= []
      end

      def models
        @models ||= []
      end

      def request_path(new_path)
        @request_path = new_path
      end

      def request(new_request, path = nil)
        requests << [path, new_request]
      end

      def requests
        @requests ||= []
      end

      def secrets(*args)
        if args.empty?
          @secrets ||= []
        else
          args.reduce(secrets) do |secrets, secret|
            secrets << "@#{secret}".to_sym
          end
        end
      end

      def requires(*args)
        requirements.concat(args)
      end

      def requirements
        @requirements ||= []
      end

      def recognizes(*args)
        recognized.concat(args)
      end

      def recognized
        @recognized ||= [:connection_options]
      end

      def validate_options(options)
        keys = []
        options.each_pair do |key, value|
          keys << key unless value.nil?
        end
        missing = requirements - keys

        unless missing.empty?
          raise ArgumentError, "Missing required arguments: #{missing.join(", ")}"
        end

        unless recognizes.empty?
          unrecognized = options.keys - requirements - recognized
          unless unrecognized.empty?
            Fog::Logger.warning("Unrecognized arguments: #{unrecognized.join(", ")}")
          end
        end
      end

      private

      # This is the original way service settings were handled. Settings from +~/.fog+ were merged
      # together with the passed options, keys are turned to symbols and coerced into Boolean or
      # Fixnums.
      #
      # If the class has declared any required settings then {ArgumentError} will be raised.
      #
      # Any setting that is not whitelisted will cause a warning to be output.
      #
      def handle_settings(settings)
        combined_settings = fetch_credentials(settings).merge(settings)
        prepared_settings = Fog::Core::Utils.prepare_service_settings(combined_settings)
        validate_options(prepared_settings)
        coerce_options(prepared_settings)
      end

      # This will attempt to require all model files declared by the service using fog"s DSL
      def require_models
        model_files.each { |model| require_item(model, @model_path) }
      end

      def require_collections_and_define
        collection_files.each do |collection|
          require_item(collection, @model_path)
          constant = camel_case_collection_name(collection.last)
          service::Collections.module_eval <<-EOS, __FILE__, __LINE__
            def #{collection.last}(attributes = {})
              #{service}::#{constant}.new({ :service => self }.merge(attributes))
            end
          EOS
        end
      end

      # This converts names of collections from Symbols as defined in the DSL (+:database_server+)
      # into CamelCase version (+DatabaseServer+) for metaprogramming skulduggery.
      #
      # @param [String,Symbol] collection The name of the collection broken with underscores
      # @return [String] in camel case
      def camel_case_collection_name(collection)
        collection.to_s.split("_").map(&:capitalize).join
      end

      # This will attempt to require all request files declared in the service using fog"s DSL
      def require_requests_and_mock
        requests.each do |request|
          require_item(request, @request_path)
          if service::Mock.method_defined?(request.last)
            mocked_requests << request.last
          else
            service::Mock.module_eval <<-EOS, __FILE__, __LINE__
              def #{request.last}(*args)
                Fog::Mock.not_implemented
              end
            EOS
          end
        end
      end

      # Requires the correct file for an item (collection, model, or request).
      #
      # @param [Array] item
      #   An item to require. Should be an array in the form of [path, file].
      # @param [String] fallback_dir
      #   The directory to look for the file in if the first element of `item`
      #   is nil.
      # @return [Boolean] Returns the same as `Kernel#require`.
      def require_item(item, fallback_dir)
        path, file = item
        require File.join(path || fallback_dir, file.to_s)
      end
    end
  end
end
