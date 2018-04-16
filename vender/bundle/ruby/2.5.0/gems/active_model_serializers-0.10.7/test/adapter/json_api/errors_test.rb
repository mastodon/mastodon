require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      class ErrorsTest < Minitest::Test
        include ActiveModel::Serializer::Lint::Tests

        def setup
          @resource = ModelWithErrors.new
        end

        def test_active_model_with_error
          options = {
            serializer: ActiveModel::Serializer::ErrorSerializer,
            adapter: :json_api
          }

          @resource.errors.add(:name, 'cannot be nil')

          serializable_resource = ActiveModelSerializers::SerializableResource.new(@resource, options)
          assert_equal serializable_resource.serializer_instance.attributes, {}
          assert_equal serializable_resource.serializer_instance.object, @resource

          expected_errors_object = {
            errors: [
              {
                source: { pointer: '/data/attributes/name' },
                detail: 'cannot be nil'
              }
            ]
          }
          assert_equal serializable_resource.as_json, expected_errors_object
        end

        def test_active_model_with_multiple_errors
          options = {
            serializer: ActiveModel::Serializer::ErrorSerializer,
            adapter: :json_api
          }

          @resource.errors.add(:name, 'cannot be nil')
          @resource.errors.add(:name, 'must be longer')
          @resource.errors.add(:id, 'must be a uuid')

          serializable_resource = ActiveModelSerializers::SerializableResource.new(@resource, options)
          assert_equal serializable_resource.serializer_instance.attributes, {}
          assert_equal serializable_resource.serializer_instance.object, @resource

          expected_errors_object = {
            errors: [
              { source: { pointer: '/data/attributes/name' }, detail: 'cannot be nil' },
              { source: { pointer: '/data/attributes/name' }, detail: 'must be longer' },
              { source: { pointer: '/data/attributes/id' }, detail: 'must be a uuid' }
            ]
          }
          assert_equal serializable_resource.as_json, expected_errors_object
        end

        # see http://jsonapi.org/examples/
        def test_parameter_source_type_error
          parameter = 'auther'
          error_source = ActiveModelSerializers::Adapter::JsonApi::Error.error_source(:parameter, parameter)
          assert_equal({ parameter: parameter }, error_source)
        end

        def test_unknown_source_type_error
          value = 'auther'
          assert_raises(ActiveModelSerializers::Adapter::JsonApi::Error::UnknownSourceTypeError) do
            ActiveModelSerializers::Adapter::JsonApi::Error.error_source(:hyper, value)
          end
        end
      end
    end
  end
end
