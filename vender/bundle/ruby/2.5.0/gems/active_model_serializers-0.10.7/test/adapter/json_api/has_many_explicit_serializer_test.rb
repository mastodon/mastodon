require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      # Test 'has_many :assocs, serializer: AssocXSerializer'
      class HasManyExplicitSerializerTest < ActiveSupport::TestCase
        def setup
          @post = Post.new(title: 'New Post', body: 'Body')
          @author = Author.new(name: 'Jane Blogger')
          @author.posts = [@post]
          @post.author = @author
          @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
          @post.comments = [@first_comment, @second_comment]
          @first_comment.post = @post
          @first_comment.author = nil
          @second_comment.post = @post
          @second_comment.author = nil
          @blog = Blog.new(id: 23, name: 'AMS Blog')
          @post.blog = @blog

          @serializer = PostPreviewSerializer.new(@post)
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(
            @serializer,
            include: [:comments, :author]
          )
        end

        def test_includes_comment_ids
          expected = {
            data: [
              { type: 'comments', id: '1' },
              { type: 'comments', id: '2' }
            ]
          }

          assert_equal(expected, @adapter.serializable_hash[:data][:relationships][:comments])
        end

        def test_includes_linked_data
          # If CommentPreviewSerializer is applied correctly the body text will not be present in the output
          expected = [
            {
              id: '1',
              type: 'comments',
              relationships: {
                post: { data: { type: 'posts', id: @post.id.to_s } }
              }
            },
            {
              id: '2',
              type: 'comments',
              relationships: {
                post: { data: { type: 'posts', id: @post.id.to_s } }
              }
            },
            {
              id: @author.id.to_s,
              type: 'authors',
              relationships: {
                posts: { data: [{ type: 'posts', id: @post.id.to_s }] }
              }
            }
          ]

          assert_equal(expected, @adapter.serializable_hash[:included])
        end

        def test_includes_author_id
          expected = {
            data: { type: 'authors', id: @author.id.to_s }
          }

          assert_equal(expected, @adapter.serializable_hash[:data][:relationships][:author])
        end

        def test_explicit_serializer_with_null_resource
          @post.author = nil

          expected = { data: nil }

          assert_equal(expected, @adapter.serializable_hash[:data][:relationships][:author])
        end

        def test_explicit_serializer_with_null_collection
          @post.comments = []

          expected = { data: [] }

          assert_equal(expected, @adapter.serializable_hash[:data][:relationships][:comments])
        end
      end
    end
  end
end
