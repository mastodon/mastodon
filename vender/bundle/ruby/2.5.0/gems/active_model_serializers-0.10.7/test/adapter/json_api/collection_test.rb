require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class CollectionTest < ActiveSupport::TestCase
        def setup
          @author = Author.new(id: 1, name: 'Steve K.')
          @author.bio = nil
          @blog = Blog.new(id: 23, name: 'AMS Blog')
          @first_post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
          @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')
          @first_post.comments = []
          @second_post.comments = []
          @first_post.blog = @blog
          @second_post.blog = nil
          @first_post.author = @author
          @second_post.author = @author
          @author.posts = [@first_post, @second_post]

          @serializer = ActiveModel::Serializer::CollectionSerializer.new([@first_post, @second_post])
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(@serializer)
          ActionController::Base.cache_store.clear
        end

        def test_include_multiple_posts
          expected = [
            {
              id: '1',
              type: 'posts',
              attributes: {
                title: 'Hello!!',
                body: 'Hello, world!!'
              },
              relationships: {
                comments: { data: [] },
                blog: { data: { type: 'blogs', id: '999' } },
                author: { data: { type: 'authors', id: '1' } }
              }
            },
            {
              id: '2',
              type: 'posts',
              attributes: {
                title: 'New Post',
                body: 'Body'
              },
              relationships: {
                comments: { data: [] },
                blog: { data: { type: 'blogs', id: '999' } },
                author: { data: { type: 'authors', id: '1' } }
              }
            }
          ]

          assert_equal(expected, @adapter.serializable_hash[:data])
        end

        def test_limiting_fields
          actual = ActiveModelSerializers::SerializableResource.new(
            [@first_post, @second_post],
            adapter: :json_api,
            fields: { posts: %w(title comments blog author) }
          ).serializable_hash
          expected = [
            {
              id: '1',
              type: 'posts',
              attributes: {
                title: 'Hello!!'
              },
              relationships: {
                comments: { data: [] },
                blog: { data: { type: 'blogs', id: '999' } },
                author: { data: { type: 'authors', id: '1' } }
              }
            },
            {
              id: '2',
              type: 'posts',
              attributes: {
                title: 'New Post'
              },
              relationships: {
                comments: { data: [] },
                blog: { data: { type: 'blogs', id: '999' } },
                author: { data: { type: 'authors', id: '1' } }
              }
            }
          ]
          assert_equal(expected, actual[:data])
        end
      end
    end
  end
end
