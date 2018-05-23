require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class HasOneTest < ActiveSupport::TestCase
        def setup
          @author = Author.new(id: 1, name: 'Steve K.')
          @bio = Bio.new(id: 43, content: 'AMS Contributor')
          @author.bio = @bio
          @bio.author = @author
          @post = Post.new(id: 42, title: 'New Post', body: 'Body')
          @anonymous_post = Post.new(id: 43, title: 'Hello!!', body: 'Hello, world!!')
          @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          @post.comments = [@comment]
          @anonymous_post.comments = []
          @comment.post = @post
          @comment.author = nil
          @post.author = @author
          @anonymous_post.author = nil
          @blog = Blog.new(id: 1, name: 'My Blog!!')
          @blog.writer = @author
          @blog.articles = [@post, @anonymous_post]
          @author.posts = []
          @author.roles = []

          @virtual_value = VirtualValue.new(id: 1)

          @serializer = AuthorSerializer.new(@author)
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(@serializer, include: [:bio, :posts])
        end

        def test_includes_bio_id
          expected = { data: { type: 'bios', id: '43' } }

          assert_equal(expected, @adapter.serializable_hash[:data][:relationships][:bio])
        end

        def test_includes_linked_bio
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(@serializer, include: [:bio])

          expected = [
            {
              id: '43',
              type: 'bios',
              attributes: {
                content: 'AMS Contributor',
                rating: nil
              },
              relationships: {
                author: { data: { type: 'authors', id: '1' } }
              }
            }
          ]

          assert_equal(expected, @adapter.serializable_hash[:included])
        end

        def test_has_one_with_virtual_value
          serializer = VirtualValueSerializer.new(@virtual_value)
          adapter = ActiveModelSerializers::Adapter::JsonApi.new(serializer)

          expected = {
            data: {
              id: '1',
              type: 'virtual-values',
              relationships: {
                maker: { data: { type: 'makers', id: '1' } },
                reviews: { data: [{ type: 'reviews', id: '1' },
                                  { type: 'reviews', id: '2' }] }
              }
            }
          }

          assert_equal(expected, adapter.serializable_hash)
        end
      end
    end
  end
end
