require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class Json
      class Collection < ActiveSupport::TestCase
        def setup
          @author = Author.new(id: 1, name: 'Steve K.')
          @first_post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
          @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')
          @first_post.comments = []
          @second_post.comments = []
          @first_post.author = @author
          @second_post.author = @author
          @blog = Blog.new(id: 1, name: 'My Blog!!')
          @first_post.blog = @blog
          @second_post.blog = nil

          ActionController::Base.cache_store.clear
        end

        def test_with_serializer_option
          @blog.special_attribute = 'Special'
          @blog.articles = [@first_post, @second_post]
          serializer = ActiveModel::Serializer::CollectionSerializer.new([@blog], serializer: CustomBlogSerializer)
          adapter = ActiveModelSerializers::Adapter::Json.new(serializer)

          expected = { blogs: [{
            id: 1,
            special_attribute: 'Special',
            articles: [{ id: 1, title: 'Hello!!', body: 'Hello, world!!' }, { id: 2, title: 'New Post', body: 'Body' }]
          }] }
          assert_equal expected, adapter.serializable_hash
        end

        def test_include_multiple_posts
          serializer = ActiveModel::Serializer::CollectionSerializer.new([@first_post, @second_post])
          adapter = ActiveModelSerializers::Adapter::Json.new(serializer)

          expected = { posts: [{
            title: 'Hello!!',
            body: 'Hello, world!!',
            id: 1,
            comments: [],
            author: {
              id: 1,
              name: 'Steve K.'
            },
            blog: {
              id: 999,
              name: 'Custom blog'
            }
          }, {
            title: 'New Post',
            body: 'Body',
            id: 2,
            comments: [],
            author: {
              id: 1,
              name: 'Steve K.'
            },
            blog: {
              id: 999,
              name: 'Custom blog'
            }
          }] }
          assert_equal expected, adapter.serializable_hash
        end

        def test_root_is_underscored
          virtual_value = VirtualValue.new(id: 1)
          serializer = ActiveModel::Serializer::CollectionSerializer.new([virtual_value])
          adapter = ActiveModelSerializers::Adapter::Json.new(serializer)

          assert_equal 1, adapter.serializable_hash[:virtual_values].length
        end

        def test_include_option
          serializer = ActiveModel::Serializer::CollectionSerializer.new([@first_post, @second_post])
          adapter = ActiveModelSerializers::Adapter::Json.new(serializer, include: '')
          actual = adapter.serializable_hash
          expected = { posts: [{ id: 1, title: 'Hello!!', body: 'Hello, world!!' },
                               { id: 2, title: 'New Post', body: 'Body' }] }

          assert_equal(expected, actual)
        end

        def test_fields_with_no_associations_include_option
          actual = ActiveModelSerializers::SerializableResource.new(
            [@first_post, @second_post], adapter: :json, fields: [:id], include: []
          ).as_json

          expected = { posts: [{
            id: 1
          }, {
            id: 2
          }] }

          assert_equal(expected, actual)
        end
      end
    end
  end
end
