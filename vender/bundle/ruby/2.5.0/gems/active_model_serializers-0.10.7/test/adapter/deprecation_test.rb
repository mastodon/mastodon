require 'test_helper'
module ActiveModel
  class Serializer
    module Adapter
      class DeprecationTest < ActiveSupport::TestCase
        class PostSerializer < ActiveModel::Serializer
          attribute :body
        end
        setup do
          post = Post.new(id: 1, body: 'Hello')
          @serializer = PostSerializer.new(post)
        end

        def test_null_adapter_serialization_deprecation
          expected = {}
          assert_deprecated do
            assert_equal(expected, Null.new(@serializer).as_json)
          end
        end

        def test_json_adapter_serialization_deprecation
          expected = { post: { body: 'Hello' } }
          assert_deprecated do
            assert_equal(expected, Json.new(@serializer).as_json)
          end
        end

        def test_jsonapi_adapter_serialization_deprecation
          expected = {
            data: {
              id: '1',
              type: 'posts',
              attributes: {
                body: 'Hello'
              }
            }
          }
          assert_deprecated do
            assert_equal(expected, JsonApi.new(@serializer).as_json)
          end
        end

        def test_attributes_adapter_serialization_deprecation
          expected = { body: 'Hello' }
          assert_deprecated do
            assert_equal(expected, Attributes.new(@serializer).as_json)
          end
        end

        def test_adapter_create_deprecation
          assert_deprecated do
            Adapter.create(@serializer)
          end
        end

        def test_adapter_adapter_map_deprecation
          assert_deprecated do
            Adapter.adapter_map
          end
        end

        def test_adapter_adapters_deprecation
          assert_deprecated do
            Adapter.adapters
          end
        end

        def test_adapter_adapter_class_deprecation
          assert_deprecated do
            Adapter.adapter_class(:json_api)
          end
        end

        def test_adapter_register_deprecation
          assert_deprecated do
            begin
              Adapter.register(:test, Class.new)
            ensure
              Adapter.adapter_map.delete('test')
            end
          end
        end

        def test_adapter_lookup_deprecation
          assert_deprecated do
            Adapter.lookup(:json_api)
          end
        end

        private

        def assert_deprecated
          assert_output(nil, /deprecated/) do
            yield
          end
        end
      end
    end
  end
end
