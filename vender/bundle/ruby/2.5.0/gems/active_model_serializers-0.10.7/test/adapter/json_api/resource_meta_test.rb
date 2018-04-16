require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class ResourceMetaTest < Minitest::Test
          class MetaHashPostSerializer < ActiveModel::Serializer
            attributes :id
            meta stuff: 'value'
          end

          class MetaBlockPostSerializer < ActiveModel::Serializer
            attributes :id
            meta do
              { comments_count: object.comments.count }
            end
          end

          class MetaBlockPostBlankMetaSerializer < ActiveModel::Serializer
            attributes :id
            meta do
              {}
            end
          end

          class MetaBlockPostEmptyStringSerializer < ActiveModel::Serializer
            attributes :id
            meta do
              ''
            end
          end

          def setup
            @post = Post.new(id: 1337, comments: [], author: nil)
          end

          def test_meta_hash_object_resource
            hash = ActiveModelSerializers::SerializableResource.new(
              @post,
              serializer: MetaHashPostSerializer,
              adapter: :json_api
            ).serializable_hash
            expected = {
              stuff: 'value'
            }
            assert_equal(expected, hash[:data][:meta])
          end

          def test_meta_block_object_resource
            hash = ActiveModelSerializers::SerializableResource.new(
              @post,
              serializer: MetaBlockPostSerializer,
              adapter: :json_api
            ).serializable_hash
            expected = {
              :"comments-count" => @post.comments.count
            }
            assert_equal(expected, hash[:data][:meta])
          end

          def test_meta_object_resource_in_array
            post2 = Post.new(id: 1339, comments: [Comment.new])
            posts = [@post, post2]
            hash = ActiveModelSerializers::SerializableResource.new(
              posts,
              each_serializer: MetaBlockPostSerializer,
              adapter: :json_api
            ).serializable_hash
            expected = {
              data: [
                { id: '1337', type: 'posts', meta: { :"comments-count" => 0 } },
                { id: '1339', type: 'posts', meta: { :"comments-count" => 1 } }
              ]
            }
            assert_equal(expected, hash)
          end

          def test_meta_object_blank_omitted
            hash = ActiveModelSerializers::SerializableResource.new(
              @post,
              serializer: MetaBlockPostBlankMetaSerializer,
              adapter: :json_api
            ).serializable_hash
            refute hash[:data].key? :meta
          end

          def test_meta_object_empty_string_omitted
            hash = ActiveModelSerializers::SerializableResource.new(
              @post,
              serializer: MetaBlockPostEmptyStringSerializer,
              adapter: :json_api
            ).serializable_hash
            refute hash[:data].key? :meta
          end
        end
      end
    end
  end
end
