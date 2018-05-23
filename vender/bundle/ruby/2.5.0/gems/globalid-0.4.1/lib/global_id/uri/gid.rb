require 'uri/generic'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/indifferent_access'

module URI
  class GID < Generic
    # URI::GID encodes an app unique reference to a specific model as an URI.
    # It has the components: app name, model class name, model id and params.
    # All components except params are required.
    #
    # The URI format looks like "gid://app/model_name/model_id".
    #
    # Simple metadata can be stored in params. Useful if your app has multiple databases,
    # for instance, and you need to find out which one to look up the model in.
    #
    # Params will be encoded as query parameters like so
    # "gid://app/model_name/model_id?key=value&another_key=another_value".
    #
    # Params won't be typecast, they're always strings.
    # For convenience params can be accessed using both strings and symbol keys.
    #
    # Multi value params aren't supported. Any params encoding multiple values under
    # the same key will return only the last value. For example, when decoding
    # params like "key=first_value&key=last_value" key will only be last_value.
    #
    # Read the documentation for +parse+, +create+ and +build+ for more.
    alias :app :host
    attr_reader :model_name, :model_id, :params

    # Raised when creating a Global ID for a model without an id
    class MissingModelIdError < URI::InvalidComponentError; end

    class << self
      # Validates +app+'s as URI hostnames containing only alphanumeric characters
      # and hyphens. An ArgumentError is raised if +app+ is invalid.
      #
      #   URI::GID.validate_app('bcx')     # => 'bcx'
      #   URI::GID.validate_app('foo-bar') # => 'foo-bar'
      #
      #   URI::GID.validate_app(nil)       # => ArgumentError
      #   URI::GID.validate_app('foo/bar') # => ArgumentError
      def validate_app(app)
        parse("gid://#{app}/Model/1").app
      rescue URI::Error
        raise ArgumentError, 'Invalid app name. ' \
          'App names must be valid URI hostnames: alphanumeric and hyphen characters only.'
      end

      # Create a new URI::GID by parsing a gid string with argument check.
      #
      #   URI::GID.parse 'gid://bcx/Person/1?key=value'
      #
      # This differs from URI() and URI.parse which do not check arguments.
      #
      #   URI('gid://bcx')             # => URI::GID instance
      #   URI.parse('gid://bcx')       # => URI::GID instance
      #   URI::GID.parse('gid://bcx/') # => raises URI::InvalidComponentError
      def parse(uri)
        generic_components = URI.split(uri) << nil << true # nil parser, true arg_check
        new(*generic_components)
      end

      # Shorthand to build a URI::GID from an app, a model and optional params.
      #
      #   URI::GID.create('bcx', Person.find(5), database: 'superhumans')
      def create(app, model, params = nil)
        build app: app, model_name: model.class.name, model_id: model.id, params: params
      end

      # Create a new URI::GID from components with argument check.
      #
      # The allowed components are app, model_name, model_id and params, which can be
      # either a hash or an array.
      #
      # Using a hash:
      #
      #   URI::GID.build(app: 'bcx', model_name: 'Person', model_id: '1', params: { key: 'value' })
      #
      # Using an array, the arguments must be in order [app, model_name, model_id, params]:
      #
      #   URI::GID.build(['bcx', 'Person', '1', key: 'value'])
      def build(args)
        parts = Util.make_components_hash(self, args)
        parts[:host] = parts[:app]
        parts[:path] = "/#{parts[:model_name]}/#{CGI.escape(parts[:model_id].to_s)}"

        if parts[:params] && !parts[:params].empty?
          parts[:query] = URI.encode_www_form(parts[:params])
        end

        super parts
      end
    end

    def to_s
      # Implement #to_s to avoid no implicit conversion of nil into string when path is nil
      "gid://#{app}#{path}#{'?' + query if query}"
    end

    protected
      def set_path(path)
        set_model_components(path) unless defined?(@model_name) && @model_id
        super
      end

      # Ruby 2.2 uses #query= instead of #set_query
      def query=(query)
        set_params parse_query_params(query)
        super
      end

      # Ruby 2.1 or less uses #set_query to assign the query
      def set_query(query)
        set_params parse_query_params(query)
        super
      end

      def set_params(params)
        @params = params
      end

    private
      COMPONENT = [ :scheme, :app, :model_name, :model_id, :params ].freeze

      # Extracts model_name and model_id from the URI path.
      PATH_REGEXP = %r(\A/([^/]+)/?([^/]+)?\z)

      def check_host(host)
        validate_component(host)
        super
      end

      def check_path(path)
        validate_component(path)
        set_model_components(path, true)
      end

      def check_scheme(scheme)
        if scheme == 'gid'
          super
        else
          raise URI::BadURIError, "Not a gid:// URI scheme: #{inspect}"
        end
      end

      def set_model_components(path, validate = false)
        _, model_name, model_id = path.match(PATH_REGEXP).to_a
        model_id = CGI.unescape(model_id) if model_id

        validate_component(model_name) && validate_model_id(model_id, model_name) if validate

        @model_name = model_name
        @model_id = model_id
      end

      def validate_component(component)
        return component unless component.blank?

        raise URI::InvalidComponentError,
          "Expected a URI like gid://app/Person/1234: #{inspect}"
      end

      def validate_model_id(model_id, model_name)
        return model_id unless model_id.blank?

        raise MissingModelIdError, "Unable to create a Global ID for " \
          "#{model_name} without a model id."
      end

      def parse_query_params(query)
        Hash[URI.decode_www_form(query)].with_indifferent_access if query
      end
  end

  @@schemes['GID'] = GID
end
