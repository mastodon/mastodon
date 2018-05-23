require 'test_helper'

module ActiveModelSerializers
  module Test
    class SchemaTest < ActionController::TestCase
      include ActiveModelSerializers::Test::Schema

      class MyController < ActionController::Base
        def index
          render json: profile
        end

        def show
          index
        end

        def name_as_a_integer
          profile.name = 1
          index
        end

        def render_using_json_api
          render json: profile, adapter: :json_api
        end

        def invalid_json_body
          render json: ''
        end

        private

        def profile
          @profile ||= Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
        end
      end

      tests MyController

      def test_that_assert_with_a_valid_schema
        get :index
        assert_response_schema
      end

      def test_that_raises_a_minitest_error_with_a_invalid_schema
        message = "#/name: failed schema #/properties/name: For 'properties/name', \"Name 1\" is not an integer. and #/description: failed schema #/properties/description: For 'properties/description', \"Description 1\" is not a boolean."

        get :show

        error = assert_raises Minitest::Assertion do
          assert_response_schema
        end
        assert_equal(message, error.message)
      end

      def test_that_raises_error_with_a_custom_message_with_a_invalid_schema
        message = 'oh boy the show is broken'
        exception_message = "#/name: failed schema #/properties/name: For 'properties/name', \"Name 1\" is not an integer. and #/description: failed schema #/properties/description: For 'properties/description', \"Description 1\" is not a boolean."
        expected_message = "#{message}: #{exception_message}"

        get :show

        error = assert_raises Minitest::Assertion do
          assert_response_schema(nil, message)
        end
        assert_equal(expected_message, error.message)
      end

      def test_that_assert_with_a_custom_schema
        get :show
        assert_response_schema('custom/show.json')
      end

      def test_that_assert_with_a_hyper_schema
        get :show
        assert_response_schema('hyper_schema.json')
      end

      def test_simple_json_pointers
        get :show
        assert_response_schema('simple_json_pointers.json')
      end

      def test_simple_json_pointers_that_doesnt_match
        get :name_as_a_integer

        assert_raises Minitest::Assertion do
          assert_response_schema('simple_json_pointers.json')
        end
      end

      def test_json_api_schema
        get :render_using_json_api
        assert_response_schema('render_using_json_api.json')
      end

      def test_that_assert_with_a_custom_schema_directory
        original_schema_path = ActiveModelSerializers.config.schema_path
        ActiveModelSerializers.config.schema_path = 'test/support/custom_schemas'

        get :index
        assert_response_schema

        ActiveModelSerializers.config.schema_path = original_schema_path
      end

      def test_with_a_non_existent_file
        message = 'No Schema file at test/support/schemas/non-existent.json'

        get :show

        error = assert_raises ActiveModelSerializers::Test::Schema::MissingSchema do
          assert_response_schema('non-existent.json')
        end
        assert_equal(message, error.message)
      end

      def test_that_raises_with_a_invalid_json_body
        # message changes from JSON gem 2.0.2 to 2.2.0
        message = /A JSON text must at least contain two octets!|unexpected token at ''/

        get :invalid_json_body

        error = assert_raises ActiveModelSerializers::Test::Schema::InvalidSchemaError do
          assert_response_schema('custom/show.json')
        end

        assert_match(message, error.message)
      end
    end
  end
end
