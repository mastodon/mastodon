module ActiveModelSerializers
  module Test
    module Schema
      # A Minitest Assertion that test the response is valid against a schema.
      # @param schema_path [String] a custom schema path
      # @param message [String] a custom error message
      # @return [Boolean] true when the response is valid
      # @return [Minitest::Assertion] when the response is invalid
      # @example
      #   get :index
      #   assert_response_schema
      def assert_response_schema(schema_path = nil, message = nil)
        matcher = AssertResponseSchema.new(schema_path, request, response, message)
        assert(matcher.call, matcher.message)
      end

      def assert_request_schema(schema_path = nil, message = nil)
        matcher = AssertRequestSchema.new(schema_path, request, response, message)
        assert(matcher.call, matcher.message)
      end

      # May be renamed
      def assert_request_response_schema(schema_path = nil, message = nil)
        assert_request_schema(schema_path, message)
        assert_response_schema(schema_path, message)
      end

      def assert_schema(payload, schema_path = nil, message = nil)
        matcher = AssertSchema.new(schema_path, request, response, message, payload)
        assert(matcher.call, matcher.message)
      end

      MissingSchema = Class.new(Minitest::Assertion)
      InvalidSchemaError = Class.new(Minitest::Assertion)

      class AssertSchema
        attr_reader :schema_path, :request, :response, :message, :payload

        # Interface may change.
        def initialize(schema_path, request, response, message, payload = nil)
          require_json_schema!
          @request = request
          @response = response
          @payload = payload
          @schema_path = schema_path || schema_path_default
          @message = message
          @document_store = JsonSchema::DocumentStore.new
          add_schema_to_document_store
        end

        def call
          json_schema.expand_references!(store: document_store)
          status, errors = json_schema.validate(response_body)
          @message = [message, errors.map(&:to_s).to_sentence].compact.join(': ')
          status
        end

        protected

        attr_reader :document_store

        def controller_path
          request.filtered_parameters.with_indifferent_access[:controller]
        end

        def action
          request.filtered_parameters.with_indifferent_access[:action]
        end

        def schema_directory
          ActiveModelSerializers.config.schema_path
        end

        def schema_full_path
          "#{schema_directory}/#{schema_path}"
        end

        def schema_path_default
          "#{controller_path}/#{action}.json"
        end

        def schema_data
          load_json_file(schema_full_path)
        end

        def response_body
          load_json(response.body)
        end

        def request_params
          request.env['action_dispatch.request.request_parameters']
        end

        def json_schema
          @json_schema ||= JsonSchema.parse!(schema_data)
        end

        def add_schema_to_document_store
          Dir.glob("#{schema_directory}/**/*.json").each do |path|
            schema_data = load_json_file(path)
            extra_schema = JsonSchema.parse!(schema_data)
            document_store.add_schema(extra_schema)
          end
        end

        def load_json(json)
          JSON.parse(json)
        rescue JSON::ParserError => ex
          raise InvalidSchemaError, ex.message
        end

        def load_json_file(path)
          load_json(File.read(path))
        rescue Errno::ENOENT
          raise MissingSchema, "No Schema file at #{schema_full_path}"
        end

        def require_json_schema!
          require 'json_schema'
        rescue LoadError
          raise LoadError, "You don't have json_schema installed in your application. Please add it to your Gemfile and run bundle install"
        end
      end
      class AssertResponseSchema < AssertSchema
        def initialize(*)
          super
          @payload = response_body
        end
      end
      class AssertRequestSchema < AssertSchema
        def initialize(*)
          super
          @payload = request_params
        end
      end
    end
  end
end
